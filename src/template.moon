Utils = require("src.utils")


parse_input = (input) -> input


part_one = (data) ->
    0


part_two = (data) ->
    0


parts:
    [1]:
        read: Utils.read_lines
        parse: parse_input
        solution: part_one
        tests: 0
    [2]:
        read: Utils.read_lines
        parse: parse_input
        solution: part_two
        tests: 0
