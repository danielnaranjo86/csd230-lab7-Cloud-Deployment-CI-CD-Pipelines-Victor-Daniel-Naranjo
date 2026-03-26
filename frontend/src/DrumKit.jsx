import { useState } from 'react';
import { useAuth } from './provider/authProvider';

function DrumKit({ id, brand, pieces, price, onDelete, onUpdate, onAddToCart }) {
    const { isAdmin } = useAuth();

    const [isEditing, setIsEditing] = useState(false);
    const [tempBrand, setTempBrand] = useState(brand);
    const [tempPieces, setTempPieces] = useState(pieces);
    const [tempPrice, setTempPrice] = useState(price);

    const handleSave = () => {
        const updatedDrumKit = {
            id,
            brand: tempBrand,
            pieces: parseInt(tempPieces),
            price: parseFloat(tempPrice)
        };
        onUpdate(id, updatedDrumKit);
        setIsEditing(false);
    };

    if (isEditing) {
        return (
            <div className="book-row editing">
                <input
                    type="text"
                    value={tempBrand}
                    onChange={(e) => setTempBrand(e.target.value)}
                />
                <input
                    type="number"
                    value={tempPieces}
                    onChange={(e) => setTempPieces(e.target.value)}
                />
                <input
                    type="number"
                    step="0.01"
                    value={tempPrice}
                    onChange={(e) => setTempPrice(e.target.value)}
                />
                <button onClick={handleSave} className="btn-save">Save</button>
                <button onClick={() => setIsEditing(false)}>Cancel</button>
            </div>
        );
    }

    return (
        <div className="book-row">
            <div className="book-info">
                <h3>{brand}</h3>
                <p>
                    <strong>Pieces:</strong> {pieces} |
                    <strong> Price:</strong> ${Number(price).toFixed(2)}
                </p>
            </div>

            <div className="book-actions">
                <button
                    onClick={() => onAddToCart(id)}
                    style={{ backgroundColor: '#28a745', color: 'white' }}
                >
                    🛒 Add to Cart
                </button>

                {isAdmin && (
                    <>
                        <button
                            onClick={() => setIsEditing(true)}
                            style={{ backgroundColor: '#ffc107' }}
                        >
                            Edit
                        </button>
                        <button
                            onClick={() => onDelete(id)}
                            style={{ backgroundColor: '#ff4444', color: 'white' }}
                        >
                            Delete
                        </button>
                    </>
                )}
            </div>
        </div>
    );
}

export default DrumKit;