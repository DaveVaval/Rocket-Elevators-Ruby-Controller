class Column
    attr_accessor :id, :status, :amountOfFloors, :amountOfElevators
    def initialize(id, status, amountOfFloors, amountOfElevators)
        @ID = id
        @status = status
        @amountOfFloors = amountOfFloors
        @amountOfElevators = amountOfElevators
        @callButtonsList = []
        @elevatorsList = []
        # On initiation the column will create it's call buttons
        button_floor = 1
        button_id = 1
        for index in 1..@amountOfFloors
            if button_floor < self.amountOfFloors
                callbutton = CallButton.new(button_id, 'off', button_floor, 'up')
                @callButtonsList.push(callbutton)
                button_id += 1
            end
            if button_floor > 1
                callbutton = CallButton.new(button_id, 'off', button_floor, 'down')
                @callButtonsList.push(callbutton)
                button_id += 1
            end 
            button_floor += 1
        end
        # On initiation the column will create it's elevators
        elevator_id = 1
        for index in 1..@amountOfElevators
            elevator = Elevator.new(elevator_id, 'idle', self.amountOfFloors, 1)
            @elevatorsList.push(elevator)
            elevator_id += 1
        end
    end
    # Since class attributes in ruby are private, I need to use setters and getters to be able to
    # access them from outsite of the class
    def get_elevatorsList
        @elevatorsList
    end
    
    def elevatorsList=(elevatorsList)
        @elevatorsList = elevatorsList
    end

    # This method will be called whenever a user requests an elevator
    def requestElevator(requestedFloor, direction)
        elevator = findElevator(requestedFloor, direction)
        elevator.get_floorRequestList.push(requestedFloor)
        elevator.move
        elevator.open_door
        return elevator
    end
    # Finding the best elevator by comparing scores is managed by this method
    def findElevator(requestedFloor, requested_direction)
        elevator_info = {
            :best_elevator => nil,
            :best_score => 5,
            :reference_gap => Float::INFINITY
        }
        @elevatorsList.each do |elevator|
            if requestedFloor == elevator.currentFloor and elevator.status == 'idle' and requested_direction == elevator.get_direction
                elevator_info = check_elevator(1, elevator, elevator_info, requestedFloor)
            elsif requestedFloor > elevator.currentFloor and elevator.get_direction == 'up' and requested_direction == elevator.get_direction
                elevator_info = check_elevator(2, elevator, elevator_info, requestedFloor)
            elsif requestedFloor < elevator.currentFloor and elevator.get_direction == 'down' and requested_direction == elevator.get_direction
                elevator_info = check_elevator(2, elevator, elevator_info, requestedFloor)
            elsif elevator.status == 'idle'
                elevator_info = check_elevator(3, elevator, elevator_info, requestedFloor)
            else
                elevator_info = check_elevator(4, elevator, elevator_info, requestedFloor)
            end
            return elevator_info[:best_elevator]
        end
    end

    def check_elevator(base_score, elevator, elevator_info, floor)
        if base_score < elevator_info[:best_score]
            elevator_info[:best_score] = base_score
            elevator_info[:best_elevator] = elevator
            elevator_info[:reference_gap] = (elevator.currentFloor - floor).abs
        elsif elevator_info[:best_score] == base_score
            if elevator_info[:reference_gap] > (elevator.currentFloor - floor).abs
            elevator_info[:best_score] = base_score
            elevator_info[:best_elevator] = elevator
            elevator_info[:reference_gap] = (elevator.currentFloor - floor).abs
            end
        end
        return elevator_info
    end

end

# Elevator
class Elevator
    attr_accessor :id, :status, :amountOfFloors, :currentFloor
    def initialize(id, status, amountOfFloors, currentFloor)
        @ID = id
        @status = status
        @amountOfFloors = amountOfFloors
        @currentFloor = currentFloor
        @direction = nil
        @door = Door.new(id, 'closed')
        @floorButtonsList = []
        @floorRequestList = []
        # On initiation the elevator will create it's own buttons
        floor_number = 1
        for index in 1..@amountOfFloors
            floor_button = FloorRequestButton.new(floor_number, 'off', floor_number)
            @floorButtonsList.push(floor_button)
            floor_number += 1
        end
    end
    # Getters and setters for the floor request list
    def get_floorRequestList
        @floorRequestList
    end
    
    def floorRequestList=(floorRequestList)
        @floorRequestList = floorRequestList
    end
    # Getters and setters for the direction
    def get_direction
        @direction
    end
    
    def direction=(direction)
        @direction = direction
    end
     # Getters and setters for the door
     def get_door
        @door
    end
    
    def door=(door)
        @door = door
    end
    # This method will push the requested floor to the request list
    # and calls the elevator to move and open it's door 
    def requestFloor(requestedFloor)
        @floorRequestList.push(requestedFloor)
        sort_floorRequestList
        move
        open_door
    end 

    def move()
        while @floorRequestList.length != 0
            destination = @floorRequestList[0]
            @status = 'moving'
            if @currentFloor < destination
                @direction = 'up'
                while @currentFloor < destination
                    @currentFloor += 1
                end
            elsif @currentFloor > destination
                @direction = 'down'
                while @currentFloor > destination
                    @currentFloor -= 1
                end
            end
            @status = 'idle'
            @floorRequestList.shift # Once the floor is reached it will delete the floor from the request List
        end
    end

    def sort_floorRequestList()
        if @direction == 'up'
            @floorRequestList.sort # This will sort the request list ascending
        else
            @floorRequestList.sort{|a,b| b <=> a} # This will sort the request list descending
        end
    end

    def open_door()
        @door.status = 'open'
        @door.status = 'closed'
    end

end

# Call Button
class CallButton
    attr_accessor :id, :status, :floor, :direction
    def initialize(id, status, floor, direction)
        @ID = id
        @status = status
        @floor = floor
        @direction = direction
    end
end

# Floor Request Button
class FloorRequestButton
    attr_accessor :id, :status, :floor
    def initialize(id, status, floor)
        @ID = id
        @status = status
        @floor = floor
    end
end

# door
class Door
    attr_accessor :id, :status
    def initialize(id, status)
        @ID = id
        @status = status
    end
end

#-------------------------------------------------------------------------// Testing //----------------------------------------------------------------

column = Column.new(1, 'online', 10, 2)


# Setting the base variables for this scenario
column.get_elevatorsList[0].currentFloor = 2
column.get_elevatorsList[1].currentFloor = 6

puts 'User is on floor 3 and wants to go up to floor 7'
elevator = column.requestElevator(3, 'up')
puts elevator.currentFloor
puts 'Elevator A is sent to floor: ' + column.get_elevatorsList[0].currentFloor.to_s
puts 'User enters the elevator and presses of floor 7'
elevator.requestFloor(7)
puts '...'
puts 'User reaches floor ' + column.get_elevatorsList[0].currentFloor.to_s + ' and gets out'






# test_column = Column.new(1, 'online', 10, 2)

# puts test_column.get_elevator_list[0].get_floorRequestList

# test_column.get_elevator_list[0].get_floorRequestList.push(8)

# puts test_column.get_elevator_list[0].get_floorRequestList

# test_column.get_elevator_list[1].direction = 'what?'

# puts test_column.get_elevator_list[1].get_direction
# test_column.get_elevator_list.each{ |n| puts 'hello'}

# testElevator = Elevator.new(1, 'lol', 10, 1)

