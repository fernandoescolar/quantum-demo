namespace qsharp
{
    open Microsoft.Quantum.Intrinsic;
    
    operation Set(q: Qubit, value: Result): Unit
    {
        let current = M(q);
        if (current != value)
        {
            X(q);
        }
    }

    operation SetAndReturn(desired: Result, q: Qubit): Result
    {
        Set(q, desired);
        let res = M(q);
        return res;
    }

    operation TestSet(count: Int, initial: Result): (Int, Int)
    {
        mutable numOnes = 0;
        using (qubits = Qubit[1])
        {
            for (test in 1..count)
            {
                let res = SetAndReturn(initial, qubits[0]);
                if (res == One)
                {
                    set numOnes = numOnes + 1;
                }
            }

            ResetAll(qubits);
        }

        return (count - numOnes, numOnes);
    }
}