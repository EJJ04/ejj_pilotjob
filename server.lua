ESX = exports["es_extended"]:getSharedObject()

lib.callback.register('ejj_pilotjob:AddPilotLicense', function(source)
    local identifier = GetPlayerIdentifier(source, 0)

    local existingLicense = MySQL.Sync.fetchScalar('SELECT owner FROM user_licenses WHERE owner = @owner AND type = @type', {
        ['@owner'] = identifier,
        ['@type'] = 'pilot'
    })

    if existingLicense then
        return false
    else
        local result = MySQL.Sync.execute('INSERT INTO user_licenses (type, owner) VALUES (@type, @owner)', {
            ['@type'] = 'pilot',
            ['@owner'] = identifier
        })

        if result > 0 then
            print("Pilot license successfully added.")
            return true
        else
            print("Failed to add pilot license.")
            return false
        end
    end
end)

lib.callback.register('ejj_pilotjob:HasPilotLicense', function(source)
    local identifier = GetPlayerIdentifier(source, 0)

    local licenseExists = MySQL.Sync.fetchScalar('SELECT owner FROM user_licenses WHERE owner = @owner AND type = @type', {
        ['@owner'] = identifier,
        ['@type'] = 'pilot'
    })

    if licenseExists then
        return true
    else
        return false
    end
end)