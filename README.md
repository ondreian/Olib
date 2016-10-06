## Olib [![Build Status](https://travis-ci.org/ondreian/Olib.svg?branch=master)](https://travis-ci.org/ondreian/Olib)

`gem install Olib`

This offers a lot of syntatic sugar for scripting in GS.

examples:

``` ruby
Creatures.magical.each { |creature|
 creature.kill
}
```

``` ruby
Group.members.each { |char|
 haste(char)
}
```

[WIP documentation](http://www.rubydoc.info/github/ondreian/Olib/Olib/)

Pull requests and the like as welcome.
