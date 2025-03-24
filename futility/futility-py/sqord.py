import re
import typing as t
from argparse import ArgumentParser

from git import Repo

arg_parser = ArgumentParser()
arg_parser.add_argument("ref_start", nargs="?", type=str, default="")
arg_parser.add_argument("ref_end", nargs="?", type=str, default="")


def main():
    """
    For each file changed since master, show the commits where it was changed.
    """
    args = arg_parser.parse_args()
    args.ref_start
    print("args", args)

    repo = Repo()
    print(repo.head.commit.tree)

    # sq = blocks_to_sqord(blocks)
    # for path, commits in sq.path_to_commits.items():
    #     print(path)
    #     for commit in commits:
    #         edit = next(e for e in sq.commit_to_edits[commit] if e.path == path)
    #         print(f"\t{commit.ref}\t{edit.status}")


class Sqord(t.NamedTuple):
    class Commit(t.NamedTuple):
        ref: str
        message: str

    class Edit(t.NamedTuple):
        path: str
        status: str

    @classmethod
    def empty(cls):
        return cls({}, {})

    commit_to_edits: t.Dict[Commit, t.List[Edit]]
    path_to_commits: t.Dict[str, t.List[Commit]]


if __name__ == "__main__":
    main()
