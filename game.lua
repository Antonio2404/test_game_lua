-- Для отображения русского языка
os.execute("chcp 65001 > nul")

local Game = {}
Game.__index = Game

-- Константы
local WIDTH = 10
local HEIGHT = 10
local COLORS = {'A', 'B', 'C', 'D', 'E', 'F'}

function Game:new()
    local obj = {}
    setmetatable(obj, Game)
    obj.field = {}
    obj:init()
    return obj
end

-- 1. init() - Создание поля
function Game:init()
    self.field = {}
    for y = 1, HEIGHT do
        self.field[y] = {}
        for x = 1, WIDTH do
            self.field[y][x] = COLORS[math.random(#COLORS)]
        end
    end

    -- Убедимся, что нет готовых комбинаций при старте
    while self:hasMatches() do
        self:mix()
    end
end

-- 2. tick() - Выполнение действий на поле
function Game:tick()
    local changed = false
    local anyChanges = false

    repeat
        changed = false

        -- Удаляем совпадения
        local toRemove = self:findMatches()
        if toRemove and #toRemove > 0 then
            self:removeGems(toRemove)
            changed = true
            anyChanges = true

            -- Смещаем кристаллы вниз
            self:gravity()

            -- Добавляем новые кристаллы сверху
            self:fillEmpty()
        end
    until not changed

    return anyChanges
end

-- 3. move(from, to) - Выполнение хода игрока
function Game:move(x, y, direction)
    local directions = {
        l = {dx = -1, dy = 0},
        r = {dx = 1, dy = 0},
        u = {dx = 0, dy = -1},
        d = {dx = 0, dy = 1}
    }

    if not directions[direction] then
        return false, "Неверное направление"
    end

    local dx, dy = directions[direction].dx, directions[direction].dy
    local newX, newY = x + dx + 1, y + dy + 1

    -- Проверка границ
    if newX < 1 or newX > WIDTH or newY < 1 or newY > HEIGHT then
        return false, "Ход за пределы поля"
    end

    -- Сохраняем оригинальное состояние для отката
    local originalField = {}
    for i = 1, HEIGHT do
        originalField[i] = {}
        for j = 1, WIDTH do
            originalField[i][j] = self.field[i][j]
        end
    end

    -- Меняем местами кристаллы
    local temp = self.field[y+1][x+1]
    self.field[y+1][x+1] = self.field[newY][newX]
    self.field[newY][newX] = temp

    -- Проверяем, создал ли ход совпадение
    local hasMatch = self:hasMatches()

    if not hasMatch then
        -- Отменяем ход, если не создал совпадение
        self.field = originalField
        return false, "Ход не создал комбинацию"
    end

    return true, "Ход выполнен успешно!"
end

-- 4. mix() - Перемешивание поля
function Game:mix()
    -- Собираем все кристаллы в один список
    local allGems = {}
    for y = 1, HEIGHT do
        for x = 1, WIDTH do
            table.insert(allGems, self.field[y][x])
        end
    end

    -- Перемешиваем
    for i = #allGems, 2, -1 do
        local j = math.random(i)
        allGems[i], allGems[j] = allGems[j], allGems[i]
    end

    -- Заполняем поле
    local index = 1
    for y = 1, HEIGHT do
        for x = 1, WIDTH do
            self.field[y][x] = allGems[index]
            index = index + 1
        end
    end

    -- Убеждаемся, что нет готовых комбинаций
    while self:hasMatches() do
        self:mix()
    end
end

-- 5. dump() - Вывод поля на экран
function Game:dump()
    -- Заголовок с номерами столбцов
    io.write("   ")
    for x = 0, WIDTH - 1 do
        io.write(x .. " ")
    end
    io.write("\n")

    -- Разделительная линия
    io.write("  -")
    for x = 1, WIDTH * 2 do
        io.write("-")
    end
    io.write("\n")

    -- Поле с номерами строк
    for y = 1, HEIGHT do
        io.write((y - 1) .. " | ")
        for x = 1, WIDTH do
            io.write(self.field[y][x] .. " ")
        end
        io.write("\n")
    end
end

-- Вспомогательные методы
function Game:findMatches()
    local toRemove = {}

    -- Проверка горизонтальных совпадений
    for y = 1, HEIGHT do
        local count = 1
        local currentColor = self.field[y][1]
        local startX = 1

        for x = 2, WIDTH do
            if self.field[y][x] == currentColor then
                count = count + 1
            else
                if count >= 3 then
                    for i = startX, startX + count - 1 do
                        table.insert(toRemove, {x = i, y = y})
                    end
                end
                count = 1
                currentColor = self.field[y][x]
                startX = x
            end
        end

        if count >= 3 then
            for i = startX, startX + count - 1 do
                table.insert(toRemove, {x = i, y = y})
            end
        end
    end

    -- Проверка вертикальных совпадений
    for x = 1, WIDTH do
        local count = 1
        local currentColor = self.field[1][x]
        local startY = 1

        for y = 2, HEIGHT do
            if self.field[y][x] == currentColor then
                count = count + 1
            else
                if count >= 3 then
                    for i = startY, startY + count - 1 do
                        table.insert(toRemove, {x = x, y = i})
                    end
                end
                count = 1
                currentColor = self.field[y][x]
                startY = y
            end
        end

        if count >= 3 then
            for i = startY, startY + count - 1 do
                table.insert(toRemove, {x = x, y = i})
            end
        end
    end

    return toRemove
end

function Game:hasMatches()
    local matches = self:findMatches()
    return matches and #matches > 0
end

function Game:removeGems(toRemove)
    for _, pos in ipairs(toRemove) do
        self.field[pos.y][pos.x] = " "
    end
end

function Game:gravity()
    for x = 1, WIDTH do
        -- Собираем все непустые кристаллы в столбце
        local column = {}
        for y = HEIGHT, 1, -1 do
            if self.field[y][x] ~= " " then
                table.insert(column, self.field[y][x])
            end
        end

        -- Заполняем столбец снизу вверх
        for y = HEIGHT, 1, -1 do
            local index = HEIGHT - y + 1
            if index <= #column then
                self.field[y][x] = column[index]
            else
                self.field[y][x] = " "
            end
        end
    end
end

function Game:fillEmpty()
    for x = 1, WIDTH do
        for y = 1, HEIGHT do
            if self.field[y][x] == " " then
                self.field[y][x] = COLORS[math.random(#COLORS)]
            end
        end
    end
end

function Game:hasPossibleMoves()
    -- Упрощенная проверка - всегда true
    return true
end

-- Основной цикл игры
local function main()
    math.randomseed(os.time())

    local game = Game:new()

    print("=== ИГРА MATCH-3 ===")
    print("Команды:")
    print("  m x y d - переместить кристалл из (x,y) в направлении")
    print("             (l-влево, r-вправо, u-вверх, d-вниз)")
    print("  q - выйти из игры")
    print("")
    print("Пример: m 3 0 r - переместить кристалл из (3,0) вправо")
    print("")

    game:dump()

    while true do
        io.write("> ")
        local input = io.read()

        if input == "q" then
            print("До свидания!")
            break
        end

        local command, x, y, d = input:match("^(%a)%s*(%d*)%s*(%d*)%s*(%a*)$")

        if command == "m" and x and y and d then
            x = tonumber(x)
            y = tonumber(y)

            if x and y and x >= 0 and x < WIDTH and y >= 0 and y < HEIGHT then
                local success, message = game:move(x, y, d)
                print(message)

                if success then
                    -- Обрабатываем совпадения
                    local changes
                    repeat
                        changes = game:tick()
                        if changes then
                            print("Удаляем совпадения...")
                            game:dump()
                            -- Небольшая пауза для визуализации
                            for i = 1, 10000000 do end
                        end
                    until not changes

                    -- Проверяем возможные ходы
                    if not game:hasPossibleMoves() then
                        print("Нет возможных ходов, перемешиваем...")
                        game:mix()
                    end

                    game:dump()
                end
            else
                print("Ошибка: Неверные координаты")
            end
        else
            print("Ошибка: Неверная команда. Используйте: m x y d или q")
        end
    end
end

-- Запуск игры
if arg and arg[0]:match("game.lua") then
    main()
end

return Game