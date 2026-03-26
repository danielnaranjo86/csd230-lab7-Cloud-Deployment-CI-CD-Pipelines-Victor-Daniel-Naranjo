import { useState } from 'react';
import { useAuth } from './provider/authProvider';

function GuitarForm({ onGuitarAdded, api }) {
    const { isAdmin } = useAuth();

    const [brand, setBrand] = useState('');
    const [model, setModel] = useState('');
    const [price, setPrice] = useState('');

    if (!isAdmin) {
        return <h3>Access denied.</h3>;
    }

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const res = await api.post('/guitars', {
                brand,
                model,
                price: parseFloat(price)
            });
            onGuitarAdded(res.data);
            setBrand('');
            setModel('');
            setPrice('');
            alert("Guitar Saved!");
        } catch (err) {
            alert("Save failed.");
        }
    };

    return (
        <form onSubmit={handleSubmit} className="form-style">
            <h3>Add New Guitar</h3>
            <input type="text" value={brand} onChange={(e) => setBrand(e.target.value)} placeholder="Brand" required />
            <input type="text" value={model} onChange={(e) => setModel(e.target.value)} placeholder="Model" required />
            <input type="number" step="0.01" value={price} onChange={(e) => setPrice(e.target.value)} placeholder="Price" required />
            <button type="submit">Save Guitar</button>
        </form>
    );
}

export default GuitarForm;