require "DFCP_StopWatch.DFCP_stopwatch"

print("Starting stop watch script in 5 seconds")

function wait(sec)
    local start = os.time()
    repeat until os.time() > start + sec
end

wait(5)

print(StopWatch:Start('proxy'))

wait(3)

print(StopWatch:Start('nadel'))

wait(6)

print(StopWatch:Lap('proxy'))

wait(4)

print(StopWatch:Lap('nadel'))

wait(5)

print(StopWatch:Penalty('proxy', 5, 'out of bounds'))

wait(2)

print(StopWatch:Lap('proxy'))
print(StopWatch:Lap('nadel'))
print(StopWatch:Stop('proxy'))
print(StopWatch:Stop('nadel'))

print('-----')
print(StopWatch:GetStopWatchStatus('proxy'))

print(StopWatch:Start('nadel'))
print(StopWatch:GetStopWatchStatus('nadel'))
