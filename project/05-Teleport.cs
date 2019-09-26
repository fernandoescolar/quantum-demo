using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace qsharp
{
    public class TeleportDriver : IDriver
    {
        public void Run(QuantumSimulator qsim)
        {
            var initials = new Result[] { Result.Zero, Result.One };
            foreach (var initial in initials)
            {
                var res = MakeTeleport.Run(qsim, initial).Result;
                Console.WriteLine($"{initial} = {res}");
            }
        }
    }
}