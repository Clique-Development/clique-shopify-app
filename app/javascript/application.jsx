import {Application} from "@hotwired/stimulus";

const application = Application.start();

export {application};

import React from "react";
import {createRoot} from "react-dom/client";
import {BrowserRouter as Router} from 'react-router-dom';
import {AppProvider} from "@shopify/polaris";
import en from "@shopify/polaris/locales/en.json";
import "@shopify/polaris/build/esm/styles.css";
import IndexTableComponent from "./components/IndexTable";
import OrderIndexTableComponent from "./components/OrderIndexTable";
import CurrencySettingsComponent from "./components/CurrencySettingsComponent";


document.addEventListener("DOMContentLoaded", function () {
    const container = document.getElementById("products-index-path");
    if (container) {
        const root = createRoot(container);
        root.render(
            <AppProvider i18n={en}>
                <Router>
                    <IndexTableComponent/>
                </Router>
            </AppProvider>
        );
    }

    const order_container = document.getElementById("orders-index-path");
    if (order_container) {
        const orderRoot = createRoot(order_container);
        orderRoot.render(
            <AppProvider i18n={en}>
                <OrderIndexTableComponent/>
            </AppProvider>
        );
    }

    const price_settings_container = document.getElementById("price-settings-path");
    if (price_settings_container) {
        const root = createRoot(price_settings_container);
        root.render(
            <AppProvider i18n={en}>
                <CurrencySettingsComponent/>
            </AppProvider>
        );
    }
});
