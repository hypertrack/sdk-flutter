alias r := release
alias d := docs

release: docs
    flutter pub publish --dry-run

docs:
    dart doc
    cp -R doc/api/ docs
    rm -r doc
