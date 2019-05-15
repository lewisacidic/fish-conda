
if not set -q CONDA_ROOT
  set -l locations = anaconda anaconda3 miniconda miniconda3

  for location in $locations
    if test -e $HOME/$location
      set -g CONDA_ROOT $HOME/$location
      break
    end
  end

  if not set -q CONDA_ROOT
    echo CONDA_ROOT not set, and could not be guessed. 
    echo To enable conda, please set it to the root of your conda installation.
  end
end

set -gx CONDA_EXE $CONDA_ROOT/bin/conda
set _CONDA_ROOT $CONDA_ROOT
set _CONDA_EXE CONDA_EXE
set -gx CONDA_PYTHON_EXE CONDA_EXE

# The rest of the file is taken from conda
# See https://github.com/conda/conda/tree/master/shell/etc/fish/conf.d/conda.fish
# Copyright (C) 2012 Anaconda, Inc
# SPDX-License-Identifier: BSD-3-Clause

if not set -q CONDA_SHLVL
    set -gx CONDA_SHLVL "0"
    set -g _CONDA_ROOT (dirname (dirname $CONDA_EXE))
    set -gx PATH $_CONDA_ROOT/condabin $PATH
end

function __conda_add_prompt
  if set -q CONDA_DEFAULT_ENV
      set_color normal
      echo -n '('
      set_color -o green
      echo -n $CONDA_DEFAULT_ENV
      set_color normal
      echo -n ') '
  end
end

if functions -q fish_prompt
    functions -c fish_prompt __fish_prompt_orig
    functions -e fish_prompt
else
    function __fish_prompt_orig
    end
end

function return_last_status
  return $argv
end

function fish_prompt
  set -l last_status $status
  if set -q CONDA_LEFT_PROMPT
      __conda_add_prompt
  end
  return_last_status $last_status
  __fish_prompt_orig
end

if functions -q fish_right_prompt
    functions -c fish_right_prompt __fish_right_prompt_orig
    functions -e fish_right_prompt
else
    function __fish_right_prompt_orig
    end
end
function fish_right_prompt
  if not set -q CONDA_LEFT_PROMPT
      __conda_add_prompt
  end
  __fish_right_prompt_orig
end


function conda --inherit-variable CONDA_EXE
    if [ (count $argv) -lt 1 ]
        eval $CONDA_EXE
    else
        set -l cmd $argv[1]
        set -e argv[1]
        switch $cmd
            case activate deactivate
                eval (eval $CONDA_EXE shell.fish $cmd $argv)
            case install update upgrade remove uninstall
                eval $CONDA_EXE $cmd $argv
                and eval (eval $CONDA_EXE shell.fish reactivate)
            case '*'
                eval $CONDA_EXE $cmd $argv
        end
    end
end




# Autocompletions below


# Faster but less tested (?)
function __fish_conda_commands
  string replace -r '.*_([a-z]+)\.py$' '$1' $_CONDA_ROOT/lib/python*/site-packages/conda/cli/main_*.py
  for f in $_CONDA_ROOT/bin/conda-*
    if test -x "$f" -a ! -d "$f"
      string replace -r '^.*/conda-' '' "$f"
    end
  end
  echo activate
  echo deactivate
end

function __fish_conda_env_commands
  string replace -r '.*_([a-z]+)\.py$' '$1' $_CONDA_ROOT/lib/python*/site-packages/conda_env/cli/main_*.py
end

function __fish_conda_envs
  conda config --json --show envs_dirs | python -c "import json, os, sys; from os.path import isdir, join; print('\n'.join(d for ed in json.load(sys.stdin)['envs_dirs'] if isdir(ed) for d in os.listdir(ed) if isdir(join(ed, d))))"
end

function __fish_conda_packages
  conda list | awk 'NR > 3 {print $1}'
end

function __fish_conda_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'conda' ]
    return 0
  end
  return 1
end

function __fish_conda_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

# Conda commands
complete -f -c conda -n '__fish_conda_needs_command' -a '(__fish_conda_commands)'
complete -f -c conda -n '__fish_conda_using_command env' -a '(__fish_conda_env_commands)'

# Commands that need environment as parameter
complete -f -c conda -n '__fish_conda_using_command activate' -a '(__fish_conda_envs)'

# Commands that need package as parameter
complete -f -c conda -n '__fish_conda_using_command remove' -a '(__fish_conda_packages)'
complete -f -c conda -n '__fish_conda_using_command uninstall' -a '(__fish_conda_packages)'
complete -f -c conda -n '__fish_conda_using_command upgrade' -a '(__fish_conda_packages)'
complete -f -c conda -n '__fish_conda_using_command update' -a '(__fish_conda_packages)'