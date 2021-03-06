Utils = require("src.utils")


class BingoBoard
    new: (board) =>
        @board = board

        height = #board
        assert(height > 0)
        
        width = #(board[1])
        assert(width > 0)

        @size = :width, :height

        @marked_in_rows = for _ = 1, height do 0
        @marked_in_columns = for _ = 1, width do 0

        numbers_data = {}
        numbers_sum = 0
        for i, row in ipairs(board)
            assert(#row == width)
            for j, number in ipairs(row)
                numbers_data[number] = marked: false, position: { x: i, y: j }
                numbers_sum += number
        
        @numbers_data = numbers_data
        @numbers_sum = numbers_sum

        @marked_sum = 0
        @winning = false


    mark: (number) => 
        data = @numbers_data[number]
        return unless data

        assert(not data.marked)
        data.marked = true

        { x: row, y: col } = data.position
        @marked_in_rows[row] += 1
        @marked_in_columns[col] += 1
        @marked_sum += number

        if @marked_in_rows[row] == @size.width then
            @winning = true
            return true

        if @marked_in_columns[col] == @size.height then
            @winning = true
            return true

        false


    sum_row: (index) =>
        { :width } = @size
        assert(1 <= index and index <= width)
    
        sum = 0
        for number in *(@board[index])
            sum += number
            
        sum


    sum_column: (index) =>
        { :height } = @size
        assert(1 <= index and index <= height)

        sum = 0
        for row in *@board
            sum += row[index]
        
        sum

    print: () =>
        for row in *@board
            for number in *row do print number
            print!


get_result = (board, number) -> (board.numbers_sum - board.marked_sum) * number


parse_input = (input) ->
    _, _, order_input, boards_input = input\find("(.-)\n\n(.+)")

    marking_order = [ tonumber(number) for number in order_input\gmatch("(%d+)") ]

    boards = for board in *Utils.get_groups(boards_input, true)
        board = [ [ tonumber(number) for number in row\gmatch("(%d+)") ] for row in *board ]
        
        BingoBoard(board)

    { :marking_order, :boards }


part_one = (data) ->
    for number in *data.marking_order
        for board in *data.boards
            has_won = board\mark(number)
            return get_result(board, number) if has_won

    error("First winning board not found")


part_two = (data) ->
    board_left = #(data.boards)

    for number in *data.marking_order
        for board in *data.boards
            continue if board.winning

            has_won = board\mark(number)
            board_left -= 1 if has_won

            return get_result(board, number) if board_left == 0
    
    error("Last winning board not found")          


parts:
    [1]:
        read: Utils.read_raw
        parse: parse_input
        solution: part_one
        tests: 4512
    [2]:
        read: Utils.read_raw
        parse: parse_input
        solution: part_two
        tests: 1924
        