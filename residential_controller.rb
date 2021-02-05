# Column
class Column
    attr_accessor :id, :status, :amount_of_floors, :amount_of_elevators
    def initialize(id, status, amount_of_floors, amount_of_elevators)
        @id = id
        @status = status
        @amount_of_floors = amount_of_floors
        @amount_of_elevators = amount_of_elevators
        @call_button_list = []
        @elevator_list = []
        button_floor = 1
        button_id = 1

        for index in 1..@amount_of_floors
            if button_floor < self.amount_of_floors
                call_button = Call_Button.new(button_id, 'off', button_floor, 'up')
                @call_button_list.push(call_button)
                button_id += 1
            end
            if button_floor > 1
                call_button = Call_Button.new(button_id, 'off', button_floor, 'down')
                @call_button_list.push(call_button)
                button_id += 1
            end 
            button_floor += 1
        end 
    end
end


# Elevator
class Elevator
    attr_accessor :id, :status, :amount_of_floors, :current_floor
    def initialize(id, status, amount_of_floors, current_floor)
        @id = id
        @status = status
        @amount_of_floors = amount_of_floors
        @current_floor = current_floor
        @direction = nil
        @doors = Door.new(id, 'closed')
        @floor_button_list = []
        @floor_request_list = []
    end
end


# Call Button
class Call_Button
    attr_accessor :id, :status, :floor, :direction
    def initialize(id, status, floor, direction)
        @id = id
        @status = status
        @floor = floor
        @direction = direction
    end
end


# Floor Request Button
class Floor_Request_Button
    attr_accessor :id, :status, :floor
    def initialize(id, status, floor)
        @id = id
        @status = status
        @floor = floor
    end
end


# Doors
class Door
    attr_accessor :id, :status
    def initialize(id, status)
        @id = id
        @status = status
    end
end


#-------------------------------------------------------------------------// Testing //----------------------------------------------------------------

testColumn = Column.new(1, 'online', 10, 2)

puts testColumn.inspect