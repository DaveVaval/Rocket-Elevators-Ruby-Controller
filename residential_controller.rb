class Column
    attr_accessor :id, :status, :amount_of_floors, :amount_of_elevators
    def initialize(id, status, amount_of_floors, amount_of_elevators)
        @id = id
        @status = status
        @amount_of_floors = amount_of_floors
        @amount_of_elevators = amount_of_elevators
        @call_button_list = []
        @elevator_list = []
        # On initiation the column will create it's call buttons
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
        # On initiation the column will create it's elevators
        elevator_id = 1
        for index in 1..@amount_of_elevators
            elevator = Elevator.new(elevator_id, 'idle', self.amount_of_floors, 1)
            @elevator_list.push(elevator)
            elevator_id += 1
        end
    end
    # Since class attributes in ruby are private, I need to use setters and getters to be able to
    # access them from outsite of the class
    def get_elevator_list
        @elevator_list
    end
    
    def elevator_list=(elevator_list)
        @elevator_list = elevator_list
    end

    # This method will be called whenever a user requests an elevator
    def request_elevator(requested_floor, direction)
        elevator = find_elevator(requested_floor, direction)
        elevator.get_floor_request_list.push(requested_floor)
        elevator.move
        elevator.open_doors
        return elevator
    end
    # Finding the best elevator by comparing scores is managed by this method
    def find_elevator(requested_floor, requested_direction)
        elevator_info = {
            :best_elevator => nil,
            :best_score => 5,
            :reference_gap => Float::INFINITY
        }
        @elevator_list.each do |elevator|
            if requested_floor == elevator.current_floor and elevator.status == 'idle' and requested_direction == elevator.direction
                elevator_info = check_elevator(1, elevator, elevator_info, requested_floor)
            elsif requested_floor > elevator.current_floor and elevator.direction == 'up' and requested_direction == elevator.direction
                elevator_info = check_elevator(2, elevator, elevator_info, requested_floor)
            elsif requested_floor < elevator.current_floor and elevator.direction == 'down' and requested_direction == elevator.direction
                elevator_info = check_elevator(2, elevator, elevator_info, requested_floor)
            elsif elevator.status == 'idle'
                elevator_info = check_elevator(3, elevator, elevator_info, requested_floor)
            else
                elevator_info = check_elevator(4, elevator, elevator_info, requested_floor)
            end
            return elevator_info[:best_elevator]
        end
    end

    def check_elevator(base_score, elevator, elevator_info, floor)
        if base_score < elevator_info[:best_score]
            elevator_info[:best_score] = base_score
            elevator_info[:best_elevator] = elevator
            elevator_info[:reference_gap] = (elevator.current_floor - floor).abs
        elsif elevator_info[:best_score] == base_score
            if elevator_info[:reference_gap] > (elevator.current_floor - floor).abs
            elevator_info[:best_score] = base_score
            elevator_info[:best_elevator] = elevator
            elevator_info[:reference_gap] = (elevator.current_floor - floor).abs
            end
        end
        return elevator_info
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
        # On initiation the elevator will create it's own buttons
        floor_number = 1
        for index in 1..@amount_of_floors
            floor_button = Floor_Request_Button.new(floor_number, 'off', floor_number)
            @floor_button_list.push(floor_button)
            floor_number += 1
        end
    end

    def get_floor_request_list
        @floor_request_list
    end
    
    def floor_request_list=(floor_request_list)
        @floor_button_list = floor_request_list
    end
    # This method will push the requested floor to the request list
    # and calls the elevator to move and open it's doors 
    def request_floor(floor)
        @floor_request_list.push(floor)
        sort_floor_request_list
        move
        open_doors
    end 

    def move()
        while @floor_request_list.length != 0
            destination = @floor_request_list[0]
            @status = 'moving'
            if @current_floor < destination
                @direction = 'up'
                while @current_floor < destination
                    @current_floor += 1
                end
            elsif @current_floor > destination
                @direction = 'down'
                while @current_floor > destination
                    @current_floor -= 1
                end
            end
            @status = 'idle'
            @floor_request_list.shift # Once the floor is reached it will delete the floor from the request List
        end
    end

    def sort_floor_request_list()
        if @direction == 'up'
            @floor_request_list.sort # This will sort the request list ascending
        else
            @floor_request_list.sort{|a,b| b <=> a} # This will sort the request list descending
        end
    end

    def open_doors()
        @doors.status = 'open'
        @doors.status = 'closed'
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

# column = Column.new(1, 'online', 10, 2)

# # Setting the base variables for this scenario
# column.get_elevator_list[0].current_floor = 2
# column.get_elevator_list[1].current_floor = 6

# puts 'User is on floor 3 and wants to go up to floor 7'
# elevator = column.request_elevator(3, 'up')
# puts elevator.current_floor
# puts 'Elevator A is sent to floor:' + column.get_elevator_list[0].current_floor
# puts 'User enters the elevator and presses of floor 7'
# elevator.request_floor(7)
# puts '...'
# puts 'User reaches floor' + column.get_elevator_list[0].current_floor + 'and gets out'

test_column = Column.new(1, 'online', 10, 2)

puts test_column.get_elevator_list[0].get_floor_request_list

test_column.get_elevator_list[0].get_floor_request_list.push(8)

puts test_column.get_elevator_list[0].get_floor_request_list
# test_column.get_elevator_list.each{ |n| puts 'hello'}