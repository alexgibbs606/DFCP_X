require "DFCP_stopwatch.DFCP_stopwatch"

print("Starting stop watch script in 5 seconds")

function wait(sec)
    local start = os.time()
    repeat until os.time() > start + sec
end

wait(5)

print(Stopwatch:Start('proxy'))

wait(3)

print(Stopwatch:Start('nadel'))

wait(6)

print(Stopwatch:Lap('proxy'))

wait(4)

print(Stopwatch:Lap('nadel'))

wait(5)

print(Stopwatch:Penalty('proxy', 5, 'out of bounds'))

wait(2)

print(Stopwatch:Lap('proxy'))
print(Stopwatch:Lap('nadel'))
print(Stopwatch:Stop('proxy'))
print(Stopwatch:Stop('nadel'))

print('-----')
print(Stopwatch:GetStopwatchStatus('proxy'))

print(Stopwatch:Start('nadel'))
print(Stopwatch:GetStopwatchStatus('nadel'))
