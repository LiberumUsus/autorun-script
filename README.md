# auto-run-script

# Overview
Autorun-script executes after a file is saved if the buffer and mode meet predetermined requirements. It searches for a script, default name is `run-script.sh`, within the current directory and any parent above it up to a limit set by the user. After finding the script the script is executed asynchronously with arguments provided via settings or the default argument of the file extension.

## Execution Order
Which script and what args are executed depend on the hiearchy of settings.
When the script is called a message will be displayed in the message
echo area. And the message will be prefixed to indicate which setting is being
used.

Example: `BUF:autoscript: <path-to-script> <args>`.


The hiearchy of settings and their messeage prefix is as follows:
Setting     | Prefix | Example |
------------|--------|---------|
Buffer      | BUFF:  | |
~~File Path~~ | ~~PATH:~~ | |
Major-Mode  | MODE:  | |
System Wide | SYS:   | |


## Argument Variables
Currently arguments can have variables of the nature `{date}` or `{file}` and so on. These variables will be replaced with the appropriate value prior to calling the script.
Variable Name | Replace Value |
--------------|---------------|
"date" | (format-time-string "%d.%m.%Y")|
"datetime" | (format-time-string "%d.%m.%Y:%H:%M:%S")|
"time" | (format-time-string "%H:%M:%S:%6N")|
"path" | (buffer-file-name)|
"file" | (file-name-base (buffer-file-name))|
"ext"  | (file-name-extension (buffer-file-name))|
"dir"  | current directory|


## Customize

Run `M-x customize-group RET autorun-script RET` or set the variables.

``` emacs-lisp
;; Autorun Script File
(setq autorun-script-name "script-name.sh/bat")

;; Set active state. Note: executing `autorun-script-run`
;; runs the script regardless of active states
(setq autorun-script-active t)

;; Set whether or not the script response should be returned
;; to the buffer `*autorun-script-response*`.
(setq autorun-script-response-on t)

;; Set major-modes that autorun-script will run under.
(setq autorun-script-alist '('mode-name 'mode-name2 ...etc))
```

## TODO:
- ~~Enable changing system wide args~~
- ~~Enable changing system wide script name~~
- ~~Enable changing buffer args~~
- ~~Enable changing buffer script name~~
- ~~Enable changing mode args~~
- ~~Enable changing mode script name~~
- Path Args
- Path Script Name
- ~~Add basic arg variables~~
- Add user customizable variables
- Add variable escaping so that `{date}` etc will be based as arguments and not replaced
- Consider saving all settings via `{defcustom}` to keep values between sessions
