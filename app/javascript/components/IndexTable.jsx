import React, { useState, useEffect, useCallback } from 'react';
import './index.css'
import {
    Page,
    Card,
    IndexTable,
    ChoiceList,
    Badge,
    IndexFilters,
    LegacyCard,
    useSetIndexFiltersMode,
    useIndexResourceState,
    Avatar,
    TextContainer,
    Text,
    Box,
    LegacyStack, Icon
} from '@shopify/polaris';
import {ChevronLeftIcon, ChevronRightIcon} from "@shopify/polaris-icons";
import { useLocation } from 'react-router-dom';
import {createApp} from "@shopify/app-bridge";
import { NavigationMenu, AppLink } from '@shopify/app-bridge/actions';
import './IndexTableComponent.css';
import axios from "axios";

function IndexTableComponent() {
    const [selected, setSelected] = useState(0);
    const [summaryData, setSummaryData] = useState({
        suppliers: 0,
        brands: 0,
        inventory: 0,
        warehouse_locations: 0,
        potential_revenue: 0,
        potential_gross_profit: 0,
    });

    const location = useLocation();
    const productsUrl = document.getElementById('products-index').getAttribute('data-products-url')
    const ordersUrl = document.getElementById('orders-index').getAttribute('data-orders-url');
    const settingsUrl = document.getElementById('settings-path').getAttribute('data-settings-url');

    useEffect(() => {
        const config = {
            apiKey: "13cb39066c49258dd5f45ab029840428",
            host: new URLSearchParams(window.location.search).get('host'),
            forceRedirect: true,
        };

        const app = createApp(config);

        const productsLink = AppLink.create(app, {
            label: 'Products',
            destination: productsUrl,
        });

        const ordersLink = AppLink.create(app, {
            label: 'Orders',
            destination: ordersUrl,
        });

        const customersLink = AppLink.create(app, {
            label: 'Customers',
            destination: '/customers',
        });

        const settingsLink = AppLink.create(app, {
            label: 'Settings',
            destination: settingsUrl,
        });

        // Set up the navigation menu
        NavigationMenu.create(app, {
            items: [productsLink, ordersLink, customersLink, settingsLink],
            active: location.pathname.includes("")
                ? productsLink
                : location.pathname.includes("orders")
                    ? ordersLink
                    : location.pathname.includes("customers")
                        ? customersLink
                        : settingsLink,
        });
    }, [location]);

    //  real-time data fetching
    useEffect(() => {
        const fetchData = async () => {
            try {
                const response = await axios.get('/products_data_summary');
                const data = response.data;

                setSummaryData({
                    suppliers: data.suppliers,
                    vendors: data.brands, // Renamed to match the backend
                    inventory: data.inventory,
                    warehouseLocations: data.warehouse_locations,
                    potentialRevenue: data.potential_revenue,
                    potentialGrossProfit: data.potential_gross_profit,
                });
            } catch (error) {
                console.error('Failed to fetch summary data', error);
            }
        };

        fetchData(); // Fetch initial data
        const intervalId = setInterval(fetchData, 60000); // Polling every 60 seconds

        return () => clearInterval(intervalId); // Clean up the interval on unmount
    }, []);

    const disambiguateLabel = (key, value) => {
        switch (key) {
            case "type":
                return value.map((val) => `type: ${val}`).join(", ");
            case "tone":
                return value.map((val) => `tone: ${val}`).join(", ");
            default:
                return value;
        }
    };

    const isEmpty = (value) => {
        if (Array.isArray(value)) {
            return value.length === 0;
        } else {
            return value === "" || value == null;
        }
    };

    const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

    const [itemStrings, setItemStrings] = useState([
        "All",
        "Active",
        "Draft",
        "Due",
    ]);

    const deleteView = (index) => {
        const newItemStrings = [...itemStrings];
        newItemStrings.splice(index, 1);
        setItemStrings(newItemStrings);
        setSelected(0);
    };

    const duplicateView = async (name) => {
        setItemStrings([...itemStrings, name]);
        setSelected(itemStrings.length);
        await sleep(1);
        return true;
    };

    const tabs = itemStrings.map((item, index) => ({
        content: item,
        index,
        onAction: () => {},
        id: `${item}-${index}`,
        isLocked: index === 0,
        actions:
            index === 0
                ? []
                : [
                    {
                        type: 'rename',
                        onAction: () => {},
                        onPrimaryAction: async (value) => {
                            const newItemsStrings = tabs.map((item, idx) => {
                                if (idx === index) {
                                    return value;
                                }
                                return item.content;
                            });
                            await sleep(1);
                            setItemStrings(newItemsStrings);
                            return true;
                        },
                    },
                    {
                        type: 'duplicate',
                        onPrimaryAction: async (value) => {
                            await sleep(1);
                            await duplicateView(value);
                            return true;
                        },
                    },
                    {
                        type: 'edit',
                    },
                    {
                        type: 'delete',
                        onPrimaryAction: async () => {
                            await sleep(1);
                            deleteView(index);
                            return true;
                        },
                    },
                ],
    }));

    const onCreateNewView = async (value) => {
        await sleep(500);
        setItemStrings([...itemStrings, value]);
        setSelected(itemStrings.length);
        return true;
    };

    const sortOptions = [
        { label: "Product", value: "product asc", directionLabel: "Ascending" },
        { label: "Product", value: "product desc", directionLabel: "Descending" },
        { label: "Status", value: "tone asc", directionLabel: "A-Z" },
        { label: "Status", value: "tone desc", directionLabel: "Z-A" },
        { label: "Type", value: "type asc", directionLabel: "A-Z" },
        { label: "Type", value: "type desc", directionLabel: "Z-A" },
        { label: "Vendor", value: "vendor asc", directionLabel: "Ascending" },
        { label: "Vendor", value: "vendor desc", directionLabel: "Descending" },
    ];

    const [sortSelected, setSortSelected] = useState(["product asc"]);
    const { mode, setMode } = useSetIndexFiltersMode();

    const onHandleCancel = () => {};
    const onHandleSave = async () => {
        await sleep(1);
        return true;
    };

    const primaryAction = selected === 0
        ? {
            type: "save-as",
            onAction: onCreateNewView,
            disabled: false,
            loading: false,
        }
        : {
            type: "save",
            onAction: onHandleSave,
            disabled: false,
            loading: false,
        };

    const [tone, setStatus] = useState(undefined);
    const [type, setType] = useState(undefined);
    const [queryValue, setQueryValue] = useState("");

    const handleStatusChange = useCallback((value) => setStatus(value), []);
    const handleTypeChange = useCallback((value) => setType(value), []);
    const handleFiltersQueryChange = useCallback((value) => setQueryValue(value), []);
    const handleStatusRemove = useCallback(() => setStatus(undefined), []);
    const handleTypeRemove = useCallback(() => setType(undefined), []);
    const handleQueryValueRemove = useCallback(() => setQueryValue(""), []);
    const handleFiltersClearAll = useCallback(() => {
        handleStatusRemove();
        handleTypeRemove();
        handleQueryValueRemove();
    }, [handleStatusRemove, handleQueryValueRemove, handleTypeRemove]);

    const filters = [
        {
            key: "tone",
            label: "Status",
            filter: (
                <ChoiceList
                    title="tone"
                    titleHidden
                    choices={[
                        { label: "Active", value: "active" },
                        { label: "Draft", value: "draft" },
                        { label: "Archived", value: "archived" },
                    ]}
                    selected={tone || []}
                    onChange={handleStatusChange}
                    allowMultiple
                />
            ),
            shortcut: true,
        },
        {
            key: "type",
            label: "Type",
            filter: (
                <ChoiceList
                    title="Type"
                    titleHidden
                    choices={[
                        { label: "Brew Gear", value: "brew-gear" },
                        { label: "Brew Merch", value: "brew-merch" },
                    ]}
                    selected={type || []}
                    onChange={handleTypeChange}
                    allowMultiple
                />
            ),
            shortcut: true,
        },
    ];

    const appliedFilters = [];
    if (tone && !isEmpty(tone)) {
        const key = "tone";
        appliedFilters.push({
            key,
            label: disambiguateLabel(key, tone),
            onRemove: handleStatusRemove,
        });
    }
    if (type && !isEmpty(type)) {
        const key = "type";
        appliedFilters.push({
            key,
            label: disambiguateLabel(key, type),
            onRemove: handleTypeRemove,
        });
    }
    // const Products = () => {
    const [products, setProducts] = useState([]);
    const [currentPage, setCurrentPage] = useState(1);
    const [totalPages, setTotalPages] = useState(1);

    const { allResourcesSelected, selectedResources, handleSelectionChange } = useIndexResourceState(products);

    const resourceName = {
        singular: "Product",
        plural: "Products",
    };

    // Fetch products with pagination
    const fetchProducts = async (page = 1) => {
        try {
            const response = await axios.get('/rewix_products', {
                params: { page }
            });

            setProducts(response.data.products);
            setCurrentPage(response.data.current_page);
            setTotalPages(response.data.total_pages);
        } catch (error) {
            console.error('Error fetching products:', error);
        }
    };

    useEffect(() => {
        fetchProducts(currentPage);
    }, [currentPage]);

    const handlePrevPage = () => {
        if (currentPage > 1) {
            setCurrentPage(currentPage - 1);
        }
    };

    const handleNextPage = () => {
        if (currentPage < totalPages) {
            setCurrentPage(currentPage + 1);
        }
    };

    const rowMarkup = products.map(
        (
            {
                external_id,
                image_url,
                name,
                inventory,
                category_type,
                vendor,
                dropship_supplier,
                warehouse_location,
                subcategory,
                quantity,
                unit_cost_eur,
                cost_of_dropship_carrier_eur,
                unit_cost_usd,
                unit_cost_egp,
                cost_of_kg,
                cost_of_gram,
                unit_weight_gr,
                unit_cost_including_weight_usd,
                unit_cost_including_weight_egp,
                gross_margin,
                final_price,
                tags,
                images
            },
            index
        ) => {
            console.log(quantity, 'Unit Cost EUR');

            return (
                <IndexTable.Row id={external_id} key={external_id} selected={selectedResources.includes(external_id)} position={index}>
                    <IndexTable.Cell>
                        <Box style={{ display: "flex", alignItems: "center", gap: '10px' }}>
                            <Avatar
                                source={`https://griffati.rewix.zero11.org${image_url}`}
                            />
                            {name}
                        </Box>
                    </IndexTable.Cell>
                    <IndexTable.Cell>{<Badge tone="success">Active</Badge>}</IndexTable.Cell>
                    <IndexTable.Cell>{inventory}</IndexTable.Cell>
                    <IndexTable.Cell>{category_type}</IndexTable.Cell>
                    <IndexTable.Cell>{vendor}</IndexTable.Cell>
                    <IndexTable.Cell>{dropship_supplier}</IndexTable.Cell>
                    <IndexTable.Cell>{warehouse_location}</IndexTable.Cell>
                    <IndexTable.Cell>{subcategory}</IndexTable.Cell>
                    <IndexTable.Cell>{quantity}</IndexTable.Cell>
                    <IndexTable.Cell>{`${unit_cost_eur} EUR`}</IndexTable.Cell>
                    <IndexTable.Cell>{`${cost_of_dropship_carrier_eur} EUR`}</IndexTable.Cell>
                    <IndexTable.Cell>{`${unit_cost_usd} USD`}</IndexTable.Cell>
                    <IndexTable.Cell>{`${unit_cost_egp} EGP`}</IndexTable.Cell>
                    <IndexTable.Cell>{`${cost_of_kg} USD`}</IndexTable.Cell>
                    <IndexTable.Cell>{`${cost_of_gram} USD`}</IndexTable.Cell>
                    <IndexTable.Cell>{`${unit_weight_gr} gm`}</IndexTable.Cell>
                    <IndexTable.Cell>{`${unit_cost_including_weight_usd} USD`}</IndexTable.Cell>
                    <IndexTable.Cell>{`${unit_cost_including_weight_egp} EGP`}</IndexTable.Cell>
                    <IndexTable.Cell>{`${gross_margin} %`}</IndexTable.Cell>
                    <IndexTable.Cell>{`${final_price} EGP`}</IndexTable.Cell>
                </IndexTable.Row>
            );
        }
    );


    return (
        <Box>
            <Box paddingBlockEnd={'800'}>
                <Text variant="headingXl"  alignment={"start"} as="h1" fontWeight="bold">Product</Text>
            </Box>
            <Box  maxWidth="70%" paddingBlockEnd='600'>
                <LegacyCard  sectioned>
                    <TextContainer >

                        <div>
                            <LegacyStack distribution="equalSpacing" vertical={false} alignment="center">
                                <LegacyStack.Item fill>
                                    <Text variant="headingMd" as="h2" fontWeight="bold">Suppliers</Text>
                                    <Text variant="headingMd" fontWeight="bold">{summaryData.suppliers}</Text>
                                </LegacyStack.Item>

                                <LegacyStack.Item fill>
                                    <Box borderInlineStartWidth="025" paddingInlineStart={'500'} borderColor="border-subdued">
                                        <Text variant="headingMd" as="h2" fontWeight="bold">No. Brands</Text>
                                        <Text variant="headingMd" fontWeight="bold">{summaryData.vendors}</Text>
                                    </Box>
                                </LegacyStack.Item>

                                <LegacyStack.Item fill>
                                    <Box borderInlineStartWidth="025" paddingInlineStart={'500'}  borderColor="border-subdued">
                                        <Text variant="headingMd" as="h2" fontWeight="bold">Inventory</Text>
                                        <Text variant="headingMd" fontWeight="bold">{summaryData.inventory}</Text>
                                    </Box>
                                </LegacyStack.Item>

                                <LegacyStack.Item fill>
                                    <Box borderInlineStartWidth="025" paddingInlineStart={'500'}  borderColor="border-subdued">
                                        <Text variant="headingMd" as="h2" fontWeight="bold">Warehouse Locations</Text>
                                        <Text variant="headingMd" fontWeight="bold">{summaryData.warehouseLocations}</Text>
                                    </Box>
                                </LegacyStack.Item>

                                <LegacyStack.Item fill>
                                    <Box borderInlineStartWidth="025" paddingInlineStart={'500'}  borderColor="border-subdued">
                                        <Text variant="headingMd" as="h2" fontWeight="bold">Potential Revenue</Text>
                                        <Text variant="headingMd" fontWeight="bold">{summaryData.potentialRevenue} EGP</Text>
                                    </Box>
                                </LegacyStack.Item>

                                <LegacyStack.Item fill>
                                    <Box borderInlineStartWidth="025" paddingInlineStart={'500'} borderColor="border-subdued">
                                        <Text variant="headingMd" as="h2" fontWeight="bold">Potential Gross Profit</Text>
                                        <Text variant="headingMd" fontWeight="bold">{summaryData.potentialGrossProfit} EGP</Text>
                                    </Box>
                                </LegacyStack.Item>
                            </LegacyStack>

                        </div>
                    </TextContainer>
                </LegacyCard>
            </Box>

            <LegacyCard sectioned>
                <IndexFilters
                    sortOptions={sortOptions}
                    sortSelected={sortSelected}
                    queryValue={queryValue}
                    queryPlaceholder="Searching in all"
                    onQueryChange={handleFiltersQueryChange}
                    onQueryClear={handleQueryValueRemove}
                    primaryAction={primaryAction}
                    cancelAction={{
                        onAction: onHandleCancel,
                        disabled: false,
                    }}
                    tabs={tabs}
                    selected={selected}
                    onSortChange={setSortSelected}
                    onSelect={setSelected}
                    canCreateNewView={true}
                    filters={filters}
                    appliedFilters={appliedFilters}
                    onClearAll={handleFiltersClearAll}
                    mode={mode}
                    setMode={setMode}
                />
            </LegacyCard>

            <Card>
                <IndexTable
                    resourceName={resourceName}
                    itemCount={products.length}
                    selectedItemsCount={
                        allResourcesSelected ? "All" : selectedResources.length
                    }
                    onSelectionChange={handleSelectionChange}
                    headings={[
                        { title: "Product" },
                        { title: "Status" },
                        { title: "Inventory" },
                        { title: "Type" },
                        { title: "Vendor" },
                        { title: "DropShip Supplier" },
                        { title: 'Warehouse Location' },
                        { title: 'Subcategory' },
                        { title: 'Quantity' },
                        { title: 'Unit Cost' },
                        { title: 'Cost of Dropshipping Carrier (EUR)' },
                        { title: 'Unit Cost (USD)' },
                        { title: 'Unit Cost (EGP)' },
                        { title: 'Cost of Kg (USD)' },
                        { title: 'Cost of Gram (USD )' },
                        { title: 'Unit WeightSupplier (GR)' },
                        { title: 'Unit Cost Including Weight (USD)' },
                        { title: 'Unit Cost Including Weight (EGP)' },
                        { title: 'Gross Margin' },
                        { title: 'Final Price' }
                    ]}
                >
                    {rowMarkup}
                </IndexTable>

                {/* Pagination controls */}
                <div style={{ marginTop: '10px', display: 'flex', justifyContent: 'flex-end' }}>
                    <button
                        onClick={handlePrevPage}
                        style={{ border: 'none', background: 'transparent', cursor: 'pointer' }}
                        disabled={currentPage === 1}
                    >
                        <Icon source={ChevronLeftIcon} color="base" />
                    </button>

                    <button
                        onClick={handleNextPage}
                        style={{ border: 'none', background: 'transparent', cursor: 'pointer' }}
                        disabled={currentPage === totalPages}
                    >
                        <Icon source={ChevronRightIcon} color="base" />
                    </button>
                </div>

                <div style={{ marginTop: '10px', textAlign: 'right' }}>
                    Page {currentPage} of {totalPages}
                </div>
            </Card>
        </Box>
    );
}

export default IndexTableComponent;