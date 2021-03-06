Utils = require("src.utils")


class Passport
    EyesColors = do
        names =
            AMBER: "amb",
            BLUE: "blu",
            BROWN: "brn",
            GREY: "gry",
            GREEN: "grn",
            HAZEL: "hzl",
            OTHER: "oth"

        set = { value, true for _, value in pairs(names) }

        { NAMES: names, :set }

        
    Fields = do
        names =
            BIRTH_YEAR: "byr",
            ISSUE_YEAR: "iyr",
            EXPIRATION_YEAR: "eyr",
            HEIGHT: "hgt",
            EYE_COLOR: "ecl",
            HAIR_COLOR: "hcl",
            PASSPORT_ID: "pid",
            COUNTRY_ID: "cid"

        HEIGHT_PATTERN = "^(%d+)(%a%a)$"
        YEAR_PATTERN = "^%d%d%d%d$"
        HAIR_PATTERN = "^#%x%x%x%x%x%x$"
        PASSPORT_PATTERN = "^%d%d%d%d%d%d%d%d%d$"

        validate_year = (year, min, max) ->
            return false if not year\find(YEAR_PATTERN) 
            year = tonumber(year)
            
            min <= year and year <= max

        validators =
            [names.BIRTH_YEAR]: (v) -> validate_year(v, 1920, 2002)
            [names.ISSUE_YEAR]: (v) -> validate_year(v, 2010, 2020)
            [names.EXPIRATION_YEAR]: (v) -> validate_year(v, 2020, 2030)

            [names.HEIGHT]: (v) ->
                _, _, height, unit = v\find(HEIGHT_PATTERN)

                return false unless height and unit

                height = tonumber(height)

                switch unit
                    when "cm"
                        150 <= height and height <= 193
                    when "in"
                        59 <= height and height <= 76
                    else
                        false

            [names.EYE_COLOR]: (v) -> EyesColors.set[v]
            [names.HAIR_COLOR]: (v) -> v\find(HAIR_PATTERN)

            [names.PASSPORT_ID]: (v) -> v\find(PASSPORT_PATTERN)
            [names.COUNTRY_ID]: (v) -> true

        { NAMES: names, :validators }

    @REQUIRED_FIELD_AMOUNT: 8
    @IGNORED_FIELD: Fields.NAMES.COUNTRY_ID

    new: (group) =>
        fields, fields_amount = {}, 0

        for row in *group
            key, value = row\match("(%a%a%a):(%S+)")
            fields[key] = value
            fields_amount = fields_amount + 1
    
        @fields = fields
        @fields_amount = fields_amount


    has_required_fields: () =>
        -- n = 0..7
        if @fields_amount ~= @@REQUIRED_FIELD_AMOUNT
            -- n = 0..6
            return false if @fields_amount < @@REQUIRED_FIELD_AMOUNT - 1

            -- n = 7
            return false if @fields[@@IGNORED_FIELD]
        
        -- n = 8
        true


    has_valid_fields: () =>
        for field, value in pairs(@fields)
            return false if not Fields.validators[field](value)

        true


parse_input = (input) -> [ Passport(group) for group in *Utils.get_groups(input) ]


count_valid = (passports, is_valid) ->
    valid_amount = 0
    for passport in *passports
        valid_amount += 1 if is_valid(passport)

    valid_amount


part_one = (passports) ->
    is_valid = (passport) -> passport\has_required_fields!

    count_valid(passports, is_valid)


part_two = (passports) ->
    is_valid = (passport) -> passport\has_required_fields! and passport\has_valid_fields!
    
    count_valid(passports, is_valid)


parts:
    [1]:
        read: Utils.read_raw
        parse: parse_input
        solution: part_one
        tests: 10
    [2]:
        read: Utils.read_raw
        parse: parse_input
        solution: part_two
        tests: 6
