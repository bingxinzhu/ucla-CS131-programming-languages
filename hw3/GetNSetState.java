import java.util.concurrent.atomic.AtomicIntegerArray;
class GetNSetState implements State {
    private byte maxval;
    private AtomicIntegerArray atmoicArray;
    private void createAtomicArray(byte[] v) {
        int[] array = new int[v.length];
        for(int i = 0; i < v.length; i++) {
            array[i] = v[i];
        }
        atmoicArray = new AtomicIntegerArray(array);
    }

    GetNSetState(byte[] v) { 
        maxval = 127; 
        createAtomicArray(v);
    }

    GetNSetState(byte[] v, byte m) {  
        maxval = m; 
        createAtomicArray(v);
    }

    public int size() { return atmoicArray.length(); }

    public byte[] current() { 
        byte[] returnValue = new byte[atmoicArray.length()];
        for(int i = 0; i < returnValue.length; i++) {
            returnValue[i] = (byte)atmoicArray.get(i);
        }
        return returnValue; 
    }

    public boolean swap(int i, int j) {
	if (atmoicArray.get(i) <= 0 || atmoicArray.get(j) >= maxval) {
	    return false;
    }
    atmoicArray.set(i, atmoicArray.get(i) - 1);
    atmoicArray.set(j, atmoicArray.get(j) + 1);
	return true;
    }
}
