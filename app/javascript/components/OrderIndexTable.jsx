import React, { useState, useEffect, useCallback } from 'react';
import './index.css'
import {
    Page,
    Card,
    IndexTable,
    ChoiceList,
    TextField,
    Badge,
    IndexFilters,
    LegacyCard,
    useSetIndexFiltersMode,
    useIndexResourceState,
    Avatar,
    TextContainer,
    Text,
    Box,
    LegacyStack,
    RangeSlider,
    Divider,
    Icon
} from '@shopify/polaris';
import {ChevronLeftIcon, ChevronRightIcon} from "@shopify/polaris-icons";
import axios from "axios";
import './IndexTableComponent.css'

function OrderIndexTableComponent() {
    const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
    const [itemStrings, setItemStrings] = useState([
        'All',
        'Paid',
        'Partially Paid',
        'Due',
    ]);
    const [summaryData, setSummaryData] = useState({
        orders: 0,
        paid_orders: 0,
        paid_amount: 0,
        due_amount: 0,
    });
    useEffect(() => {
        const fetchData = async () => {
            try {
                const response = await axios.get('/orders_data_summary');
                const data = response.data;

                setSummaryData({
                    orders: data.orders,
                    paid_orders: data.paid_orders,
                    paid_amount: data.paid_amount,
                    due_amount: data.due_amount
                });
            } catch (error) {
                console.error('Failed to fetch summary data', error);
            }
        };

        fetchData(); // Fetch initial data
        const intervalId = setInterval(fetchData, 60000); // Polling every 60 seconds

        return () => clearInterval(intervalId); // Clean up the interval on unmount
    }, []);

    const [selected, setSelected] = useState(0);

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
                            duplicateView(value);
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

    const sortOptions = [
        { label: 'Order', value: 'order asc', directionLabel: 'Ascending' },
        { label: 'Order', value: 'order desc', directionLabel: 'Descending' },
        { label: 'Customer', value: 'customer asc', directionLabel: 'A-Z' },
        { label: 'Customer', value: 'customer desc', directionLabel: 'Z-A' },
        { label: 'Date', value: 'date asc', directionLabel: 'A-Z' },
        { label: 'Date', value: 'date desc', directionLabel: 'Z-A' },
        { label: 'Total', value: 'total asc', directionLabel: 'Ascending' },
        { label: 'Total', value: 'total desc', directionLabel: 'Descending' },
    ];

    const [sortSelected, setSortSelected] = useState(['order asc']);
    const { mode, setMode } = useSetIndexFiltersMode();

    const primaryAction = selected === 0
        ? {
            type: 'save-as',
            onAction: async (value) => {
                await sleep(500);
                setItemStrings([...itemStrings, value]);
                setSelected(itemStrings.length);
                return true;
            },
            disabled: false,
            loading: false,
        }
        : {
            type: 'save',
            onAction: async () => {
                await sleep(1);
                return true;
            },
            disabled: false,
            loading: false,
        };

    const [accountStatus, setAccountStatus] = useState([]);
    const [moneySpent, setMoneySpent] = useState([0, 500]);
    const [taggedWith, setTaggedWith] = useState('');
    const [queryValue, setQueryValue] = useState('');

    const handleAccountStatusChange = useCallback((value) => setAccountStatus(value), []);
    const handleMoneySpentChange = useCallback((value) => setMoneySpent(value), []);
    const handleTaggedWithChange = useCallback((value) => setTaggedWith(value), []);
    const handleFiltersQueryChange = useCallback((value) => setQueryValue(value), []);

    const filters = [
        {
            key: 'accountStatus',
            label: 'Account status',
            filter: (
                <ChoiceList
                    title="Account status"
                    titleHidden
                    choices={[
                        { label: 'Enabled', value: 'enabled' },
                        { label: 'Not invited', value: 'not invited' },
                        { label: 'Invited', value: 'invited' },
                        { label: 'Declined', value: 'declined' },
                    ]}
                    selected={accountStatus}
                    onChange={handleAccountStatusChange}
                    allowMultiple
                />
            ),
            shortcut: true,
        },
        {
            key: 'taggedWith',
            label: 'Tagged with',
            filter: (
                <TextField
                    label="Tagged with"
                    value={taggedWith}
                    onChange={handleTaggedWithChange}
                    autoComplete="off"
                    labelHidden
                />
            ),
            shortcut: true,
        },
        {
            key: 'moneySpent',
            label: 'Money spent',
            filter: (
                <RangeSlider
                    label="Money spent is between"
                    labelHidden
                    value={moneySpent}
                    prefix="$"
                    output
                    min={0}
                    max={2000}
                    step={1}
                    onChange={handleMoneySpentChange}
                />
            ),
        },
    ];

    const appliedFilters = [];
    if (accountStatus.length) {
        appliedFilters.push({
            key: 'accountStatus',
            label: `Account status: ${accountStatus.join(', ')}`,
            onRemove: () => setAccountStatus([]),
        });
    }
    if (moneySpent) {
        appliedFilters.push({
            key: 'moneySpent',
            label: `Money spent is between $${moneySpent[0]} and $${moneySpent[1]}`,
            onRemove: () => setMoneySpent([0, 500]),
        });
    }
    if (taggedWith) {
        appliedFilters.push({
            key: 'taggedWith',
            label: `Tagged with ${taggedWith}`,
            onRemove: () => setTaggedWith(''),
        });
    }


    const [orders, setOrders] = useState([]);
    const [currentPage, setCurrentPage] = useState(1);
    const [totalPages, setTotalPages] = useState(1);

    const { selectedResources, allResourcesSelected, handleSelectionChange } = useIndexResourceState(orders);

    const resourceName = {
        singular: 'order',
        plural: 'orders',
    };

    const fetchOrders = async (page = 1) => {
        try {
            const response = await axios.get('/rewix_orders', {
                params: { page }
            });

            setOrders(response.data.orders);
            setCurrentPage(response.data.current_page);
            setTotalPages(response.data.total_pages);
        } catch (error) {
            console.error('Error fetching orders:', error);
        }
    };

    useEffect(() => {
        fetchOrders(currentPage);
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

    console.log(orders)

    const rowMarkup = orders.map(({ id, name, shopify_created_at, customer, cost_of_dropshipping, total_price, financial_status }, index) => (
        <IndexTable.Row id={id} key={id} selected={selectedResources.includes(id)} position={index}>
            <IndexTable.Cell>{name}</IndexTable.Cell>
            <IndexTable.Cell>{shopify_created_at}</IndexTable.Cell>
            <IndexTable.Cell>{customer}</IndexTable.Cell>
            <IndexTable.Cell>{cost_of_dropshipping}</IndexTable.Cell>
            <IndexTable.Cell>{total_price}</IndexTable.Cell>
            <IndexTable.Cell>{financial_status}</IndexTable.Cell>
        </IndexTable.Row>
    ));

    return (


        <div style={{ padding: '16px'}}>
            <Box paddingBlockEnd={'800'}>
                <Text variant="headingXl"  alignment={"start"} as="h1" fontWeight="bold">Order</Text>
            </Box>
            <div style={{width:'45%', paddingBottom: '16px'}}>
                <Card sectioned>
                    <LegacyStack distribution="equalSpacing">
                        <Box >
                            <Text variant="bodyLg" fontWeight="bold">Orders</Text>
                            <Text variant="bodyMd">{summaryData.orders}</Text>
                        </Box>
                        <Box borderInlineStartWidth={'025'} borderColor="border-subused" paddingInlineStart={'600'}>
                            <Text variant="bodyLg" fontWeight="bold">Paid Orders</Text>
                            <Text variant="bodyMd">{summaryData.paid_orders}</Text>
                        </Box>
                        <Box borderInlineStartWidth={'025'} borderColor="border-subused" paddingInlineStart={'500'}>
                            <Text variant="bodyLg" fontWeight="bold">Paid Amounts</Text>
                            <Text variant="bodyMd">{summaryData.paid_amount}</Text>
                        </Box>
                        <Box borderInlineStartWidth={'025'} borderColor="border-subused" paddingInlineStart={'500'}>
                            <Text variant="bodyLg" fontWeight="bold">Due Amounts</Text>
                            <Text variant="bodyMd">{summaryData.due_amount}</Text>
                        </Box>
                    </LegacyStack>
                </Card>
            </div>
            <LegacyCard>
                <IndexFilters
                    tabs={tabs}
                    sortOptions={sortOptions}
                    sortSelected={sortSelected}
                    onSort={setSortSelected}
                    queryValue={queryValue}
                    onQueryChange={handleFiltersQueryChange}
                    onQueryClear={() => setQueryValue('')}
                    primaryAction={primaryAction}
                    cancelAction={{
                        type: 'cancel',
                        onAction: () => {},
                    }}
                    filters={filters}
                    appliedFilters={appliedFilters}
                    onClearAll={() => {
                        setAccountStatus([]);
                        setMoneySpent([0, 500]);
                        setTaggedWith('');
                        setQueryValue('');
                    }}
                    mode={mode}
                    setMode={setMode}
                />
                <IndexTable
                    resourceName={resourceName}
                    itemCount={orders.length}
                    selectedItemsCount={allResourcesSelected ? 'All' : selectedResources.length}
                    onSelectionChange={handleSelectionChange}
                    headings={[
                        { title: 'Order' },
                        { title: 'Date' },
                        { title: 'Customer' },
                        { title: 'Cost of Dropshipping Carrier (EUR)' },
                        { title: 'Total' },
                        { title: 'Order Status (Supplier)' },
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


            </LegacyCard>
        </div>
    );
}

export default OrderIndexTableComponent;