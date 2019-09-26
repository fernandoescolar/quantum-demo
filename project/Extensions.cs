using Microsoft.Quantum.Simulation.Core;

namespace qsharp
{
    public static class Extensions
    {
        public static int ToInt(this Result result)
        {
            return (int)result.GetValue();
        }
    }
}