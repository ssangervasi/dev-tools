#!/usr/bin/env python2.7

import sys
import json
import subprocess
from os import path


class Log(object):
    def __init__(self):
        self.level = 0

    def do(self, message, *args):
        message = message.format(*args)
        formatted = '{}[Doing: {}'.format(self.indent(), message)
        print formatted

    def did(self, message, *args):
        message = message.format(*args)
        formatted = '{} And: {}'.format(self.dent(), message)
        print formatted

    def done(self):
        print '{}]Done.'.format(self.dedent())

    def dent(self):
        return '  ' * self.level

    def indent(self):
        space = '  ' * self.level
        self.level += 1
        return space

    def dedent(self):
        self.level = max(0, self.level - 1)
        return '  ' * self.level


log = Log()


def main(command, diff_name, *args):
    log.do('Running')
    with open(diff_name) as diff_json:
        log.do('Load {} as JSON', diff_name)
        diff = json.load(diff_json)
        log.done()
    if '--load-only' in args:
        pass
    elif '--reset' in args:
        handle_reset(diff['target'])
    else:
        handle_target(diff['target'])
        results = map(handle_source, diff['sources'])
        log.did('Results={}', results)
    log.done()


def handle_target(target):
    branch = target['branch']
    create = target.get('create', False)
    create_from = target.get('from', None)
    log.do('Check out {}.', branch)
    Git.checkout_branch(branch, create, create_from)
    log.done()


def handle_reset(target):
    Git.reset(hard=True)
    Git.delete_branch(target['branch'],
                      unmerged=target['create'],
                      delete_from=target['from'])


def handle_source(source):
    log.do('Handling sources')
    title = source.get('title', None)
    pick_from = source.get('hash', None)
    if pick_from is None:
        pick_from = source.get('branch', 'master')

    base_path = source.get('base_path', path.abspath('.'))
    base_path = path.expanduser(base_path)

    def resolve_path(relative):
        resolved = path.join(base_path, relative)
        return resolved

    total_committed = 0
    for index, commit in enumerate(source['commits']):
        # Checkout file version.
        files = map(resolve_path, commit['files'])
        file_count = len(files)
        log.did('Checkout: {}', files)
        Git.checkout_file(files, pick_from)

        # Add commit info to message and commit.
        message = create_commit_message(title=title,
                                        message=commit['message'],
                                        commit_index=index,
                                        file_count=file_count,
                                        file_total=total_committed)
        log.did('Commit: {}', message)
        Git.commit(message, files)
        total_committed += file_count

    log.done()
    return total_committed


def create_commit_message(**kwargs):
    title = kwargs.pop('title', None)
    message = kwargs.pop('message', None)

    if message:
        message = message.format(**kwargs)
    if title:
        title = title.format(**kwargs)
        return '{}\n{}'.format(title, message)
    else:
        return '{}'.format(message)


class CommandLineCallable(object):
    COMMAND = 'echo'

    @classmethod
    def call(cls, *args):
        command = [arg for arg in args
                   if arg not in (None, cls.COMMAND)]
        command = [cls.COMMAND] + command
        return subprocess.call(command)


class Arc(CommandLineCallable):
    ARC = 'arc'
    DIFF = 'diff'
    TAIL = '--head'
    PREVIEW = '--preview'
    COMMAND = ARC

    @staticmethod
    def diff(head, tail=None, preview=False):
        command = [Arc.DIFF, head]
        if tail:
            command += [Arc.TAIL, tail]
        if preview:
            command.append(Arc.PREVIEW)
        Arc.call(command)


class Git(CommandLineCallable):
    GIT = 'git'
    ADD = 'add'
    CHECKOUT = 'checkout'
    BRANCH = 'branch'
    MERGE = 'merge'
    RESET = 'reset'
    HARD = '--hard'
    COMMIT = 'commit'
    MESSAGE = '-m'
    SEP = '--'

    COMMAND = GIT

    @staticmethod
    def commit(message, files=None):
        if files:
            Git.stage(*files)
        Git.call(Git.COMMIT, Git.MESSAGE, message)

    @staticmethod
    def merge(commit='HEAD'):
        Git.call(Git.MERGE, commit)

    @staticmethod
    def checkout_branch(branch, create=False, create_from=None):
        if create:
            create_from = create_from or 'HEAD'
            Git.call(Git.BRANCH, branch, create_from)
        Git.call(Git.CHECKOUT, branch)

    @staticmethod
    def delete_branch(branch, unmerged=False, delete_from=None):
        if delete_from:
            Git.checkout_branch(delete_from)
        delete = '-D' if unmerged else '--delete'
        Git.call(Git.BRANCH, branch, delete)

    @staticmethod
    def checkout_file(file, commit='HEAD'):
        command = [Git.CHECKOUT, commit]
        command.append(Git.SEP)
        if isinstance(file, list):
            command += file
        else:
            command.append(file)
        Git.call(*command)

    @staticmethod
    def stage(*args):
        Git.call(Git.ADD, *args)

    @staticmethod
    def reset(hard=False):
        command = [Git.RESET]
        if hard:
            command.append(Git.HARD)
        Git.call(*command)

if __name__ == '__main__':
    main(*sys.argv)
