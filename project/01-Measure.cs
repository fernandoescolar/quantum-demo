using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace qsharp
{
    public class MeasureDriver : IDriver
    {
        public void Run(QuantumSimulator qsim)
        {
            for (var i = 0; i < 10; i++)
            {
                var res = MeasureAll.Run(qsim).Result;
                var (resZ, resY, resX) = res;
                var z = resZ == Result.Zero ? "|0>" : "|1>";
                var y = resY == Result.Zero ? "|-i>" : "|i>";
                var x = resX == Result.Zero ? "|->" : "|+>";
                Console.WriteLine($"Z: {z,-4}, Y: {y,-4}, X: {x,-4}");
            }
        }
    }
}