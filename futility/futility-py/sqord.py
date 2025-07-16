from argparse import ArgumentParser
from os import path
from pathlib import Path
import git
import itertools as it
import typing as t

arg_parser = ArgumentParser()
arg_parser.add_argument("ref_start", nargs="?", type=str, default="")
arg_parser.add_argument("ref_end", nargs="?", type=str, default="")


def pril(*args):
    print(*args, sep="\n")


def main():
    """
    For each file changed since master, show the commits where it was changed.
    """
    args = arg_parser.parse_args()
    args.ref_start
    print("args", args)

    repo = git.Repo(cwd_git_root())

    ref_end = args.ref_end or "HEAD"
    ref_start = args.ref_start or repo.merge_base("master", ref_end)[0]

    commit_start = repo.commit(ref_start)
    commit_end = repo.commit(ref_end)

    pril(
        f"working_dir: {repo.working_dir}",
        f"start: {oneline(commit_start)}",
        f"end  : {oneline(commit_end)}",
    )

    commit_range = [commit_end]
    for i, pc in enumerate(commit_end.iter_parents()):
        if i >= 100:
            raise Exception("Too many parents")

        commit_range.append(pc)

        if pc == commit_start:
            break

    commit_range.reverse()

    pril(f"range: {len(commit_range)}", *(oneline(c) for c in commit_range))

    # File to the comits where it was modified
    path_to_edits: dict[str, list[Edit]] = {}

    for a, b in it.pairwise(commit_range):
        diffs = b.diff(a)
        for diff in diffs:
            edit = Edit.from_diff_commit(diff, b)
            acc = path_to_edits.get(edit.path, [])
            path_to_edits[edit.path] = acc
            acc.append(edit)

    # Commit to the files that were modified
    sha_to_edits: dict[str, list[Edit]] = {}

    for edit in it.chain.from_iterable(path_to_edits.values()):
        acc = sha_to_edits.get(edit.commit.hexsha, [])
        sha_to_edits[edit.commit.hexsha] = acc
        acc.append(edit)

    pril(
        "Idea: for each commit, what other commits should be"
        "squashed into it so that each file is only included in one commit"
    )

    squashable_sha_to_edits: dict[str, list[Edit]] = {}
    squashable_path_to_sha: dict[str, str] = {}

    def is_already_collected(edit: Edit):
        return edit.path in squashable_path_to_sha

    def collect(commit: git.Commit, edit: Edit):
        acc = squashable_sha_to_edits.get(commit.hexsha, [])
        squashable_sha_to_edits[commit.hexsha] = acc
        acc.append(edit)

        squashable_path_to_sha[edit.path] = commit.hexsha

    # There's a tree hiding in here...
    for commit in commit_range[1:]:
        # Every file edited in this commit
        edits = sha_to_edits[commit.hexsha]
        for edit in edits:
            path_edits = path_to_edits[edit.path]

            if is_already_collected(path_edits[0]):
                continue

            for path_edit in path_edits:
                collect(commit, path_edit)

    def is_root(commit: git.Commit):
        if not commit.hexsha in squashable_sha_to_edits:
            return False

        return len(squashable_sha_to_edits[commit.hexsha]) > 0

    roots_for_squash = [commit for commit in commit_range if is_root(commit)]

    pril(
        f"full range count: {len(commit_range)}",
        f"roots for squash len: {len(roots_for_squash)}",
    )

    for commit in roots_for_squash:
        edits_for_squash = squashable_sha_to_edits[commit.hexsha]
        shas_for_squash = set(
            [
                edit.commit.hexsha
                for edit in edits_for_squash
                if edit.commit.hexsha != commit.hexsha
            ]
        )

        pril(oneline(commit))

        for candidate in commit_range:
            if candidate.hexsha not in shas_for_squash:
                continue
            pril(f"\t{oneline(candidate)}")

    pril("")

    for commit in roots_for_squash:
        pril(oneline(commit))

        edits_for_squash = squashable_sha_to_edits[commit.hexsha]

        for edit in edits_for_squash:
            pril(f"\t{short_sha(edit.commit)}\t{edit.path}")


def cwd_git_root() -> Path:
    init_cwd = Path.cwd().resolve()
    home = Path.home()
    cur = init_cwd
    while cur.exists():
        if not cur.is_relative_to(home):
            raise Exception("Walked higher than home dir")

        if (cur / ".git").exists():
            return cur

        cur = cur.parent

    raise Exception("No git dir parent")


def short_sha(c: git.Commit):
    return c.hexsha[:10]


def oneline(c: git.Commit):
    return f"{short_sha(c)} : {c.summary}"


# Atmoic representation of a single file diffed in a single commit
class Edit(t.NamedTuple):
    path: str
    diff: git.Diff
    commit: git.Commit

    @classmethod
    def from_diff_commit(cls, diff: git.Diff, commit: git.Commit):
        return cls(cls.pick_path(diff), diff, commit)

    @classmethod
    def pick_path(cls, diff: git.Diff):
        prefer_b = diff.b_path or diff.a_path
        if not prefer_b:
            raise Exception("No path for diff")
        return prefer_b


class Squashable(t.NamedTuple):
    first: git.Commit
    rest: list[git.Commit]


if __name__ == "__main__":
    main()
