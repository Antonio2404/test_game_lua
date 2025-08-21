-- Для отображения русского языка
os.execute("chcp 65001 > nul")

print("=== ДОБРО ПОЖАЛОВАТЬ В ИГРУ MATCH-3! ===")
print()

print("ИНСТРУКЦИЯ:")
print("Цель игры: собирать линии из 3 и более одинаковых кристаллов")
print()
print("КОМАНДЫ:")
print("  m x y d - переместить кристалл")
print("    x, y - координаты (0-9)")
print("    d - направление: l(влево), r(вправо), u(вверх), d(вниз)")
print("  q - выйти из игры")
print()
print("ПРИМЕР: m 3 0 r - переместить кристалл из позиции (3,0) вправо")
print()


local WIDTH = 10
local HEIGHT = 10
local COLORS = {'A', 'B', 'C', 'D', 'E', 'F'}


local function showField()
    print("ТЕКУЩЕЕ ПОЛЕ:")
    print()
    
    -- Верхняя строка с номерами столбцов
    io.write("   ")
    for x = 0, 9 do
        io.write(x .. " ")
    end
    io.write("\n")
    
    -- Разделительная линия
    io.write("  -")
    for i = 1, 20 do
        io.write("-")
    end
    io.write("\n")
    
    -- Само поле с номерами строк
    for y = 0, 9 do
        io.write(y .. " | ")
        for x = 0, 9 do
            -- Пока просто случайные буквы для демонстрации
            io.write(COLORS[math.random(1, 6)] .. " ")
        end
        io.write("\n")
    end
    print()
end

showField()


-- Простой цикл для ввода команд
while true do
    io.write("Введите команду > ")
    local input = io.read()
    
    if input == "q" then
        print("Спасибо за игру! До свидания!")
        break
    elseif input == "show" then
        showField()
    else
        print("Пока что я только умею показывать поле (команда 'show')")
        print("и выходить из игры (команда 'q')")
        print("Скоро добавлю настоящую логику!")
    end
end