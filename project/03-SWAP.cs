using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace qsharp
{
    public class SWAPDriver : IDriver
    {
        public void Run(QuantumSimulator qsim)
        {
            var initials = new Result[] { Result.Zero, Result.One };
            foreach (var control in initials)
            {
                foreach (var target in initials)
                {
                    var res = MakeSWAP.Run(qsim, control, target).Result;
                    var (resControl, resTarget) = res;
                    var source = $"|{control.ToInt()}{target.ToInt()}>";
                    var result = $"|{resControl.ToInt()}{resTarget.ToInt()}>";
                    Console.WriteLine($"{source} -> {result}");
                }
            }
        }
    }
}