# json.sh
json.sh is a very portable JSON parser-- 
it should work in just about any shell you throw at it.
Right now, it can only parse and output variables etc
in a JSON file in a more script-friendly form, but write
support will be added later.


Usage
-------
To use json.sh, you can simply run `json.sh` with a filename as an argument.
Here's an example command and it's output:
`sh json.sh example.json`
`
/animals
/animals/pig
/animals/pig/tail
/animals/pig/tail = curly
/animals/pig/nose
/animals/pig/nose = adorable
/animals/sheep
/animals/sheep/tail
/animals/sheep/tail = short
/animals/sheep/nose
/animals/sheep/nose = ugly
`

There are also a few useful arguments you should keep note of:
| argument | description |
| --- | --- |
| `-v $string` | Only print variables with the name `$string` |
| `-s $string` | Only print the value of the variable `$string` |
| `-V $string` | Only print variables with the value `$string` |
| `-o $string` | Only print the object `$string` |

With `-v` and `-s`, for example, `$string` could be anything from `tail` to `/pig/tail` to `/animals/pig/tail`.
Same syntax goes for `-o`. `-V` is the only odd one out-- it's `$string` needs to be a variable's value, like `adorable` from `/pig/nose`.



Licensing
-----------
All of ST is released under the
[ISC](https://opensource.org/licenses/ISC) license.

