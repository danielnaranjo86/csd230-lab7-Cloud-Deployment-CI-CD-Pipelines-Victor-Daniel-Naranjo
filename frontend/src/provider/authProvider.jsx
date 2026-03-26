import { createContext, useContext, useMemo, useState } from "react";

const AuthContext = createContext();

const decodeJwtPayload = (token) => {
    if (!token || typeof token !== "string") return null;

    const parts = token.split(".");
    if (parts.length !== 3) return null;

    try {
        const base64Url = parts[1];
        const base64 = base64Url
            .replace(/-/g, "+")
            .replace(/_/g, "/")
            .padEnd(Math.ceil(base64Url.length / 4) * 4, "=");

        const jsonPayload = window.atob(base64);
        const payload = JSON.parse(jsonPayload);

        return payload && typeof payload === "object" ? payload : null;
    } catch (error) {
        console.error("Failed to decode token payload:", error);
        return null;
    }
};

const getRolesFromToken = (token) => {
    const payload = decodeJwtPayload(token);
    if (!payload) return [];

    const roles = payload.roles;

    if (Array.isArray(roles)) {
        return roles.filter((role) => typeof role === "string");
    }

    if (typeof roles === "string") {
        return [roles];
    }

    return [];
};

const AuthProvider = ({ children }) => {
    const [token, setToken_] = useState(localStorage.getItem("token"));

    const roles = useMemo(() => getRolesFromToken(token), [token]);

    const setToken = (newToken) => {
        if (newToken && typeof newToken === "string") {
            localStorage.setItem("token", newToken);
            setToken_(newToken);
        } else {
            localStorage.removeItem("token");
            setToken_(null);
        }
    };

    const contextValue = useMemo(
        () => ({
            token,
            roles,
            isAdmin: roles.includes("ROLE_ADMIN"),
            setToken,
        }),
        [token, roles]
    );

    return (
        <AuthContext.Provider value={contextValue}>
            {children}
        </AuthContext.Provider>
    );
};

export const useAuth = () => useContext(AuthContext);
export default AuthProvider;