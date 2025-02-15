Config = {}

Config.UseJob = false
Config.Job = 'pilot'
Config.MinimumCorrectAnswers = 6
Config.UseLicense = false
Config.PointDistance = 10

Config.Blips = {
    {
        coords = vector3(-1155.2538, -2715.0168, 19.8873),
        sprite = 90,  
        color = 0,  
        scale = 0.7, 
        shortrange = true,
        name = "Pilot School",
        disabled = not Config.UseLicense,
        UseJob = false
    },
    {
        coords = vector3(-1006.7886, -3006.0916, 13.9451),
        sprite = 359,  
        color = 0,   
        scale = 0.7, 
        shortrange = true,
        name = "Pilot Garage",
        disabled = false,
        UseJob = false
    },
    -- Add more blips as needed
}

Config.Ped = {
    model = "s_m_m_security_01",
    coords = vector4(-1155.2538, -2715.0168, 19.8873, 239.9084),
    invincible = true,
    blockEvents = true,
    frozen = true,

    target = {
        label = "Talk",
        icon = "fas fa-user",
        distance = 2.0,
        onSelect = function()
            local hasPilotLicense = lib.callback.await('ejj_pilotjob:HasPilotLicense', false)

            if hasPilotLicense then
                lib.notify({
                    description = 'You already have a pilot license, no need to take the quiz.',
                    type = 'inform',
                    duration = 5000,
                })
                return 
            end

            if Config.UseJob then
                if ESX.PlayerData.job.name ~= Config.Job then
                    lib.notify({
                        description = 'You are not authorized to take the quiz.',
                        type = 'error',
                        duration = 5000,
                    })
                    return
                end
            end

            local score = 0
            for i, questionData in ipairs(Config.QuizQuestions) do
                local options = {}
                for _, option in ipairs(questionData.options) do
                    table.insert(options, {label = option, value = option})
                end

                local input = lib.inputDialog("Question " .. i, {
                    {type = 'select', label = questionData.question, options = options, required = true}
                })

                if not input then return false end

                local selectedAnswer = input[1]

                if selectedAnswer == questionData.options[questionData.correctAnswer] then
                    score = score + 1
                end
            end

            if score >= Config.MinimumCorrectAnswers then
                lib.notify({
                    description = 'Congratulations! You answered ' .. score .. ' out of ' .. #Config.QuizQuestions .. ' correctly. You passed!',
                    type = 'inform',
                    duration = 5000,
                })

                lib.callback.await('ejj_pilotjob:AddPilotLicense', false)
            else
                lib.notify({
                    description = 'You answered ' .. score .. ' out of ' .. #Config.QuizQuestions .. ' correctly. You failed. Try again!',
                    type = 'error',
                    duration = 5000,
                })
            end
        end
    }
}

Config.PilotPedGarage = {
    model = "s_m_y_pilot_01",
    coords = vector4(-1006.7886, -3006.0916, 13.9451, 328.9363),
    invincible = true,
    blockEvents = true,
    frozen = true,

    target = {
        label = "Talk", 
        icon = "fas fa-user", 
        distance = 2.0, 
        onSelect = function()
            if Config.UseLicense then
                local hasPilotLicense = lib.callback.await('ejj_pilotjob:HasPilotLicense', false)

                if not hasPilotLicense then
                    lib.notify({
                        description = "You need a pilot's license to fly a plane.",
                        type = 'error',
                        duration = 5000,
                    })
                    return
                end
            end

            if Config.UseJob then
                if ESX.PlayerData.job.name ~= Config.Job then
                    lib.notify({
                        description = 'You are not authorized to fly a plane.',
                        type = 'error',
                        duration = 5000,
                    })
                    return
                end
            end

            local airplaneOptions = {}

            for _, airplane in ipairs(Config.AirplaneSpawn) do
                table.insert(airplaneOptions, {
                    title = airplane.title, 
                    icon = airplane.icon, 
                    description = airplane.description, 
                    image = 'https://docs.fivem.net/vehicles/' .. string.lower(airplane.model) .. '.webp',  
                    onSelect = function() spawnAirplane(airplane) end
                })
            end

            lib.registerContext({
                id = "airplane_garage_menu",
                title = "Select Airplane",
                canClose = true,
                options = airplaneOptions
            })

            lib.showContext("airplane_garage_menu")
        end
    }
}

Config.AirplaneSpawn = { 
    ParkCoords = vector3(-1001.2511, -2996.3762, 13.9451),
    {
        title = "Miljet.", 
        model = "miljet", 
        icon = "fas fa-plane", 
        description = "A fast jet.",
        coords = vector3(-1001.2511, -2996.3762, 13.9451),
        heading = 56.9412,
        useTaskWarp = true
    },
    {
        title = "Nimbus.", 
        model = "nimbus", 
        icon = "fas fa-plane", 
        description = "A luxury jet.",
        coords = vector3(-1001.2511, -2996.3762, 13.9451),
        heading = 56.9412,
        useTaskWarp = true
    },
    {
        title = "Shamal.", 
        model = "shamal", 
        icon = "fas fa-plane", 
        description = "A sleek and fast jet.",
        coords = vector3(-1001.2511, -2996.3762, 13.9451),
        heading = 56.9412,
        useTaskWarp = true
    }
}

Config.QuizQuestions = {
    {question = "What are the four primary forces acting on an aircraft during flight?", options = {"Lift, thrust, gravity, and drag", "Acceleration, thrust, gravity, and stability", "Lift, acceleration, maneuverability, and thrust"}, correctAnswer = 1},
    {question = "What happens when an aircraft's speed drops below stall speed?", options = {"The aircraft gains more lift", "The aircraft loses lift and may enter a stall", "The engine stops working"}, correctAnswer = 2},
    {question = "What is the purpose of flaps during landing?", options = {"Increase the aircraft's speed", "Increase lift while also increasing drag to reduce speed", "Improve maneuverability at high speeds"}, correctAnswer = 2},
    {question = "What is the 'angle of attack' in flight?", options = {"The angle between the wing's chord line and the relative wind", "The angle between the aircraft's nose and the ground", "The angle between the wing and the aircraft's longitudinal axis"}, correctAnswer = 1},
    {question = "What does the abbreviation VFR stand for?", options = {"Visual Flight Rules", "Velocity Flight Regulations", "Variable Flight Restrictions"}, correctAnswer = 1},
    {question = "Which frequency is generally used for emergency radio in aviation?", options = {"118.5 MHz", "121.5 MHz", "136.0 MHz"}, correctAnswer = 2},
    {question = "What does a red and green light combination from a control tower mean for an aircraft?", options = {"The aircraft must land immediately", "The aircraft must circle and wait for further instructions", "The runway is not clear, and the pilot should go around"}, correctAnswer = 3},
    {question = "What does the transponder code 7700 mean?", options = {"The aircraft has a communication failure", "The aircraft is experiencing an emergency", "The aircraft is being hijacked"}, correctAnswer = 2},
    {question = "What is an altimeter used for?", options = {"To show the aircraft's vertical speed", "To measure the aircraft's height above a reference surface", "To determine the aircraft's course"}, correctAnswer = 2},
    {question = "Which instrument shows the aircraft's direction relative to magnetic north?", options = {"Gyro horizon", "VOR indicator", "Magnetic compass"}, correctAnswer = 3}
}