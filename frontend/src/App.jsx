import { useState, useEffect } from 'react';
import { Routes, Route } from 'react-router';
import Navbar from './NavBar';
import Home from './Home';
import Book from './Book';
import BookForm from './BookForm';
import Magazine from './Magazine';
import MagazineForm from './MagazineForm';
import Cart from './Cart';
import Login from './pages/Login';
import Logout from './pages/Logout';
import { ProtectedRoute } from './routes/ProtectedRoute';
import { useAuth } from './provider/authProvider';
import api from './api/axiosConfig';
import './App.css';
import Guitar from './Guitar';
import GuitarForm from './GuitarForm';
import DrumKit from './DrumKit';
import DrumKitForm from './DrumKitForm';

function App() {
    const { token, isAdmin } = useAuth();
    const [books, setBooks] = useState([]);
    const [magazines, setMagazines] = useState([]);
    const [cartCount, setCartCount] = useState(0);
    const [loading, setLoading] = useState(true);
    const [guitars, setGuitars] = useState([]);
    const [drumKits, setDrumKits] = useState([]);

    useEffect(() => {
        if (!token) {
            setLoading(false);
            return;
        }

        const loadInitialData = async () => {
            try {
                const [booksRes, magsRes, guitarsRes, drumsRes, cartRes] = await Promise.all([
                    api.get('/books'),
                    api.get('/magazines'),
                    api.get('/guitars'),
                    api.get('/drums'),
                    api.get('/cart')
                ]);

                setBooks(booksRes.data);
                setMagazines(magsRes.data);
                setGuitars(guitarsRes.data);
                setDrumKits(drumsRes.data);
                setCartCount(cartRes.data.products.length);
            } catch (err) {
                console.error("Failed to load data", err);
            } finally {
                setLoading(false);
            }
        };

        loadInitialData();
    }, [token]);

    const handleAddToCart = async (productId) => {
        try {
            const res = await api.post(`/cart/add/${productId}`);
            setCartCount(res.data.products.length);
            alert("Added to cart!");
        } catch (err) {
            alert("Error adding to cart");
        }
    };

    const handleDeleteBook = async (id) => {
        if (!window.confirm("Delete book?")) return;
        await api.delete(`/books/${id}`);
        setBooks(books.filter(b => b.id !== id));
    };

    const handleUpdateBook = async (id, data) => {
        const res = await api.put(`/books/${id}`, data);
        setBooks(books.map(b => b.id === id ? res.data : b));
    };

    const handleDeleteGuitar = async (id) => {
        await api.delete(`/guitars/${id}`);
        setGuitars(guitars.filter(g => g.id !== id));
    };

    const handleUpdateGuitar = async (id, data) => {
        const res = await api.put(`/guitars/${id}`, data);
        setGuitars(guitars.map(g => g.id === id ? res.data : g));
    };

    const handleDeleteDrumKit = async (id) => {
        await api.delete(`/drums/${id}`);
        setDrumKits(drumKits.filter(d => d.id !== id));
    };

    const handleUpdateDrumKit = async (id, data) => {
        const res = await api.put(`/drums/${id}`, data);
        setDrumKits(drumKits.map(d => d.id === id ? res.data : d));
    };

    if (loading) return <h2>Loading Bookstore...</h2>;

    return (
        <div className="app-container">
            {token && <Navbar cartCount={cartCount} />}

            <Routes>
                <Route path="/login" element={<Login />} />

                <Route element={<ProtectedRoute />}>
                    <Route path="/" element={<Home />} />

                    <Route
                        path="/inventory"
                        element={
                            <div className="book-list">
                                <h1>Books</h1>
                                {books.map(b => (
                                    <Book
                                        key={b.id}
                                        {...b}
                                        onDelete={handleDeleteBook}
                                        onUpdate={handleUpdateBook}
                                        onAddToCart={handleAddToCart}
                                    />
                                ))}
                            </div>
                        }
                    />

                    <Route
                        path="/magazines"
                        element={
                            <div className="magazine-list">
                                <h1>Magazines</h1>
                                {magazines.map(m => (
                                    <Magazine
                                        key={m.id}
                                        {...m}
                                        onAddToCart={handleAddToCart}
                                        onDelete={(id) =>
                                            api.delete(`/magazines/${id}`).then(() =>
                                                setMagazines(magazines.filter(mag => mag.id !== id))
                                            )
                                        }
                                        onUpdate={(id, data) =>
                                            api.put(`/magazines/${id}`, data).then(res =>
                                                setMagazines(magazines.map(mag => mag.id === id ? res.data : mag))
                                            )
                                        }
                                    />
                                ))}
                            </div>
                        }
                    />

                    <Route
                        path="/guitars"
                        element={
                            <div className="book-list">
                                <h1>Guitars</h1>
                                {guitars.map(g => (
                                    <Guitar
                                        key={g.id}
                                        {...g}
                                        onDelete={handleDeleteGuitar}
                                        onUpdate={handleUpdateGuitar}
                                        onAddToCart={handleAddToCart}
                                    />
                                ))}
                            </div>
                        }
                    />

                    <Route
                        path="/drumkits"
                        element={
                            <div className="book-list">
                                <h1>Drum Kits</h1>
                                {drumKits.map(d => (
                                    <DrumKit
                                        key={d.id}
                                        {...d}
                                        onDelete={handleDeleteDrumKit}
                                        onUpdate={handleUpdateDrumKit}
                                        onAddToCart={handleAddToCart}
                                    />
                                ))}
                            </div>
                        }
                    />

                    <Route
                        path="/cart"
                        element={<Cart api={api} onCartChange={(count) => setCartCount(count)} />}
                    />

                    {isAdmin && (
                        <>
                            <Route
                                path="/add"
                                element={<BookForm onBookAdded={(b) => setBooks([...books, b])} api={api} />}
                            />
                            <Route
                                path="/add-magazine"
                                element={<MagazineForm onMagazineAdded={(m) => setMagazines([...magazines, m])} api={api} />}
                            />
                            <Route
                                path="/add-guitar"
                                element={<GuitarForm onGuitarAdded={(g) => setGuitars([...guitars, g])} api={api} />}
                            />
                            <Route
                                path="/add-drumkit"
                                element={<DrumKitForm onDrumKitAdded={(d) => setDrumKits([...drumKits, d])} api={api} />}
                            />
                        </>
                    )}

                    <Route path="/logout" element={<Logout />} />
                </Route>
            </Routes>
        </div>
    );
}

export default App;