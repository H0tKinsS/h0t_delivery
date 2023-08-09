Config = {}
Config.Locale = 'pl'
Config.Locales = {
    ['pl'] = {
        ['caution_receive_back']            = 'Otrzymano kaucję za pojazd służbowy',
        ['no_vehicle_for_package_remove']   = 'Brak pojazdu. Zdobądź pojazd służbowy',
        ['blip_name']                       = 'Kurier',
        ['caution_pay']                     = 'Opłacono kaucję za pojazd służbowy',
        ['no_caution_pay']                  = 'Nie posiadasz wystarczająco pieniędzy, aby opłacić kaucję.',
        ['spawn_no_free_space']             = 'Nie znaleziono wolnego miejsca',
        ['vehicle_plate_text']              = 'POST',
        ['finish_work_pay']                 = 'Otrzymano wynagrodzenie',
        ['pickup_deliveries']               = 'Załaduj wszystkie przesyłki',
        ['destination_drive']               = 'Pojedź do zaznaczonego punktu',
        ['destination_delivery_hand']       = 'Doręcz przesyłkę',
        ['destination_return_back']         = 'Wróć się na bazę',
        ['cloakroom_notify']                = 'Naciśnij ~INPUT_PICKUP~, aby otworzyć przebieralnie',
        ['cloakroom_wear_citizen']          = 'Strój prywatny',
        ['cloakroom_wear_work']             = 'Strój roboczy',
        ['cloakroom']                       = 'Przebieralnia',
        ['cloakroom_wear_citizen_notify']   = 'Zakończono pracę',
        ['cloakroom_wear_work_notify']      = 'Rozpoczęto pracę',
        ['vehicle_deleter_notify']          = 'Naciśnij ~INPUT_PICKUP~, aby zwrócić pojazd',
        ['vehicle_spawner_notiy']           = 'Naciśnij ~INPUT_PICKUP~, aby wyciągnąć pojazd',
        ['vehicle_package_pick']           = 'Naciśnij ~INPUT_PICKUP~, aby wyciągnąć przesyłkę',
        ['vehicle_remove_package']           = 'Wyciągnij przesyłkę z pojazdu',
        ['delivery_hand_notify']            = 'Naciśnij ~INPUT_PICKUP~, aby doręczyć przesyłkę'
    },
}
Config.VanModel = 'boxville2'
-- Max amount of packages to deliver --
Config.MaxPackages = 5
-- Time in Seconds --
Config.LoadTimePerPackage = 2
-- Size of detect of ride destination --
Config.RideDestinationSize = 12.1
-- Caution for vehicle spawn --
Config.CautionVehicleSpawn = 300
-- Amount to pay after succesful work --
Config.FinishWorkPayAmount = 5000
-- Zones --
Config.Zones = {
    Base = {x = 78.736122, y = 111.94139, z = 81.16819, markerId = 85},
    DeliveryReturn = {x = 53.897075, y = 117.14001, z = 79.087684},
    CloakRoom = {x = 78.736122, y = 111.94139, z = 81.16819},
    PackagePickup = {x = 66.941635, y = 124.56298, z = 79.167755},
    ReturnBase = {x = 72.389686, y = 121.90987, z = 79.187416},
    VehicleSpawner = {x = 80.846984, y = 81.804901, z = 78.6193},
    VehicleSpawn = {
        {74.915527, 98.501396, 79.003738, 69.601043},
        {84.438179, 95.106277, 80.064277, 66.603385},
        {34.534439, 79.204101, 75.260047, 248.23132},
        {63.964145, 103.52126, 79.018302, 156.51496},
        {58.640686, 90.600982, 78.632827, 159.02868},
        {57.91003, 105.28119, 79.019264, 161.86735}
    },
    VehicleDeleter = {x = 80.536743, y = 88.342704, z = 78.63694},
    DeliveryRoute = {
        -- Ride represents Ride destination, Drop represents package delivery --
        {
            Ride = {271.22567, -1890.602, 26.62787},
            Drop = {281.28799, -1897.914, 26.88516}
        },
        {
            Ride = {791.55456, -2126.689, 29.39286},
            Drop = {811.95861, -2147.097, 29.466295}
        },
        {
            Ride = {113.10641, -1560.363, 29.253965},
            Drop = {106.51605, -1567.939, 29.602731}
        },
        {
            Ride = {-808.0982, -1097.048, 10.604691},
            Drop = {-816.73, -1080.762, 11.132485}
        },
        {
            Ride = {-808.0982, -1097.048, 10.604691},
            Drop = {-822.3195, -1098.633, 11.153314}
        }
    }
}