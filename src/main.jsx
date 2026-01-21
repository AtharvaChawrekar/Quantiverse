import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "./index.css";
import './styles.css';

import App from "./App";
import { BrowserRouter } from "react-router-dom";
import { AuthContextProvider } from "./components/Auth/AuthContext";
import { NotificationProvider } from "./components/notifications/NotificationContext";

createRoot(document.getElementById("root")).render(
  <StrictMode>
    <BrowserRouter>
      <AuthContextProvider>
        <NotificationProvider>
          <App />
        </NotificationProvider>
      </AuthContextProvider>
    </BrowserRouter>
  </StrictMode>
);

// createRoot(document.getElementById("root")).render(
//   <StrictMode>
//     <BrowserRouter>
//       <AuthProvider>
//         <App /> {/* Only App, which contains all Routes */}
//       </AuthProvider>
//     </BrowserRouter>
//   </StrictMode>
// );
