import { Link } from 'react-router';
import { useAuth } from './provider/authProvider';

function Navbar({ cartCount }) {
    const { isAdmin } = useAuth();

    return (
        <nav className="navbar">
            <Link to="/">🏠 Home</Link>
            <Link to="/inventory">📚 Books</Link>
            <Link to="/magazines">📰 Magazines</Link>
            <Link to="/guitars">🎸 Guitars</Link>
            <Link to="/drumkits">🥁 Drum Kits</Link>
            <Link to="/cart">🛒 Cart ({cartCount})</Link>

            {isAdmin && (
                <>
                    <Link to="/add">➕ Add Book</Link>
                    <Link to="/add-magazine">➕ Add Magazine</Link>
                    <Link to="/add-guitar">➕ Add Guitar</Link>
                    <Link to="/add-drumkit">➕ Add DrumKit</Link>
                </>
            )}

            <Link to="/logout" style={{ color: "#ff4444", marginLeft: "auto" }}>🚪 Logout</Link>
        </nav>
    );
}
export default Navbar;