alias r := release
alias d := docs

lint:
    ktlint --format .

release: docs
    flutter pub publish --dry-run

docs: lint
    dart doc
    cp -R doc/api/ docs
    rm -r doc
