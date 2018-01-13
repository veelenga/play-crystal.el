## play-crystal.el
*https://play.crystal-lang.org integration.*

---
[![License GPLv3](https://img.shields.io/badge/license-GPL_v3-green.svg)](http://www.gnu.org/licenses/gpl-3.0.html)
[![Build Status](https://travis-ci.org/veelenga/play-crystal.el.svg?branch=master)](https://travis-ci.org/veelenga/play-crystal.el)

[play.crystal-lang.org](https://play.crystal-lang.org/) is a web resource to
submit/run/share [Crystal](https://crystal-lang.org/) code.

This package allows you to use this resource without exiting your favorite Emacs.

### Features:

* Allows to fetch code into Emacs buffers from play.crystal-lang.org
* Allows to submit code to play.crystal-lang.org directly from Emacs
* Allows to browse play.crystal-lang.org

### Usage

Run one of the predefined interactive functions.

See [Function Documentation](#function-documentation) for details.

### Function Documentation

#### `(play-crystal-insert RUN-ID)`

Insert code identified by RUN-ID into the current buffer.

#### `(play-crystal-insert-another-buffer RUN-ID)`

Insert code identified by RUN-ID into another buffer.

#### `(play-crystal-browse RUN-ID)`

Show code identified by RUN-ID in a browser using ’browse-url’.

#### `(play-crystal-submit-region)`

Create new run submitting code from the current region.

#### `(play-crystal-submit-buffer)`

Create new run submitting code from the current buffer.
