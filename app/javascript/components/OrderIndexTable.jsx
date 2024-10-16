import {
    TextField,
    IndexTable,
    LegacyCard,
    IndexFilters,
    useSetIndexFiltersMode,
    useIndexResourceState,
    Text,
    ChoiceList,
    RangeSlider,
    Badge,
    Box,
    Card,
    LegacyStack, Divider,
} from '@shopify/polaris';
import React, { useState, useCallback } from 'react';
import './IndexTableComponent.css'

function OrderIndexTableComponent() {
    const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
    const [itemStrings, setItemStrings] = useState([
        'All',
        'paid',
        'Partially Paid',
        'Due',
    ]);
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

    const orders = [
        {
            id: '1020',
            order: <Text as="span" variant="bodyMd" fontWeight="semibold">#1020</Text>,
            date: 'Jul 20 at 4:34pm',
            customer: 'Jaydon Stanton',
            total: '$969.44',
            paymentStatus: <Badge progress="complete">Paid</Badge>,
        },
        {
            id: '1019',
            order: <Text as="span" variant="bodyMd" fontWeight="semibold">#1019</Text>,
            date: 'Jul 20 at 3:46pm',
            customer: 'Ruben Westerfelt',
            total: '$701.19',
            paymentStatus: <Badge progress="partiallyComplete">Partially paid</Badge>,
        },
        {
            id: '1018',
            order: <Text as="span" variant="bodyMd" fontWeight="semibold">#1018</Text>,
            date: 'Jul 20 at 3:44pm',
            customer: 'Leo Carder',
            total: '$798.24',
            paymentStatus: <Badge progress="incomplete">Due</Badge>,
        },
    ];

    const resourceName = {
        singular: 'order',
        plural: 'orders',
    };

    const { selectedResources, allResourcesSelected, handleSelectionChange } = useIndexResourceState(orders);

    const rowMarkup = orders.map(({ id, order, date, customer, total, paymentStatus }, index) => (
        <IndexTable.Row id={id} key={id} selected={selectedResources.includes(id)} position={index}>
            <IndexTable.Cell>{order}</IndexTable.Cell>
            <IndexTable.Cell>{date}</IndexTable.Cell>
            <IndexTable.Cell>{customer}</IndexTable.Cell>
            <IndexTable.Cell>{total}</IndexTable.Cell>
            <IndexTable.Cell>{paymentStatus}</IndexTable.Cell>
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
                            <Text variant="bodyMd">200</Text>
                        </Box>
                        <Box borderInlineStartWidth={'025'} borderColor="border-subused" paddingInlineStart={'600'}>
                            <Text variant="bodyLg" fontWeight="bold">Paid Orders</Text>
                            <Text variant="bodyMd">100</Text>
                        </Box>
                        <Box borderInlineStartWidth={'025'} borderColor="border-subused" paddingInlineStart={'500'}>
                            <Text variant="bodyLg" fontWeight="bold">Paid Amounts</Text>
                            <Text variant="bodyMd">6,600 USD</Text>
                        </Box>
                        <Box borderInlineStartWidth={'025'} borderColor="border-subused" paddingInlineStart={'500'}>
                            <Text variant="bodyLg" fontWeight="bold">Due Amounts</Text>
                            <Text variant="bodyMd">5,000 USD</Text>
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
                        { title: 'Total' },
                        { title: 'Payment status' },
                    ]}
                >
                    {rowMarkup}
                </IndexTable>
            </LegacyCard>
        </div>
    );
}

export default OrderIndexTableComponent;