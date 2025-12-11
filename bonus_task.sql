-- таблицы
create table customers (
    customer_id serial primary key,
    iin char(12) unique not null,
    full_name text not null,
    phone text,
    email text,
    status text check (status in ('active','blocked','frozen')),
    created_at timestamp default now(),
    daily_limit_kzt numeric(18,2) default 2000000
);

create table accounts (
    account_id serial primary key,
    customer_id integer references customers(customer_id),
    account_number text unique not null,
    currency text check (currency in ('kzt','usd','eur','rub')),
    balance numeric(18,2) default 0,
    is_active boolean default true,
    opened_at timestamp default now(),
    closed_at timestamp
);


create table transactions (
    transaction_id serial primary key,
    from_account_id integer references accounts(account_id),
    to_account_id integer references accounts(account_id),
    amount numeric(18,2),
    currency text,
    exchange_rate numeric(18,6),
    amount_kzt numeric(18,2),
    type text,
    status text,
    created_at timestamp default now(),
    completed_at timestamp,
    description text
);

create table exchange_rates (
    rate_id serial primary key,
    from_currency text,
    to_currency text,
    rate numeric(18,6),
    valid_from timestamp,
    valid_to timestamp
);

create table audit_log (
    log_id serial primary key,
    table_name text,
    record_id integer,
    action text,
    old_values jsonb,
    new_values jsonb,
    changed_by text,
    changed_at timestamp default now(),
    ip_address text
);


insert into customers(iin, full_name, phone, email, status, daily_limit_kzt) values
('870101123456','алина есенова','+7-701-0000001','alina.e@example.com','active',1000000),
('900202234567','максат нурбаев','+7-701-0000002','maksat.n@example.com','active',2000000),
('850303345678','айдана каримова','+7-701-0000003','aidana.k@example.com','blocked',500000),
('920404456789','ерлан сайлау','+7-701-0000004','erlan.s@example.com','active',3000000),
('880505567890','жанна окушева','+7-701-0000005','zhanna.o@example.com','active',1500000),
('891111000111','серик абылов','+7-701-0000006','serik.a@example.com','frozen',1000000),
('930707707707','айгерим турсун','+7-701-0000007','aigerim.t@example.com','active',2500000),
('940808808808','дана кемел','+7-701-0000008','dana.k@example.com','active',1200000),
('950909909909','бекзат жунусов','+7-701-0000009','bekzat.j@example.com','active',1800000),
('960101101010','лилия сала','+7-701-0000010','liliya.s@example.com','active',2200000);

insert into accounts(customer_id, account_number, currency, balance, is_active) values
(1,'kz01-0001','kzt',500000,true),
(2,'kz02-0002','usd',2000,true),
(3,'kz03-0003','kzt',10000,true),
(4,'kz04-0004','eur',500,true),
(5,'kz05-0005','kzt',120000,true),
(6,'kz06-0006','rub',50000,true),
(7,'kz07-0007','kzt',300000,true),
(8,'kz08-0008','usd',1500,true),
(9,'kz09-0009','kzt',80000,true),
(10,'kz10-0010','kzt',600000,true);

insert into exchange_rates(from_currency,to_currency,rate,valid_from,valid_to) values
('USD','KZT',470.50, now() - interval '7 days', null),
('EUR','KZT',510.00, now() - interval '7 days', null),
('RUB','KZT',5.50, now() - interval '7 days', null),
('KZT','KZT',1, now() - interval '7 days', null),
('USD','EUR',0.92, now() - interval '7 days', null),
('EUR','USD',1.09, now() - interval '7 days', null),
('RUB','USD',0.012, now() - interval '30 days', null),
('USD','RUB',83.33, now() - interval '30 days', null),
('EUR','RUB',88.00, now() - interval '30 days', null),
('RUB','EUR',0.011, now() - interval '30 days', null);


insert into transactions(from_account_id,to_account_id,amount,currency,exchange_rate,amount_kzt,type,status,description,created_at) values
(1,5,50000,'kzt',1,50000,'transfer','completed','платеж поставщику', now() - interval '2 days'),
(7,9,100000,'kzt',1,100000,'transfer','completed','перевод другу', now() - interval '1 day'),
(2,8,100,'usd',470.5,47050,'transfer','completed','пополнение счета', now() - interval '6 hours'),
(10,1,150000,'kzt',1,150000,'transfer','completed','зарплата', now() - interval '3 days'),
(5,3,8000,'kzt',1,8000,'withdrawal','completed','снятие наличных', now() - interval '10 days'),
(4,2,50,'eur',510,25500,'transfer','completed','оплата услуг', now() - interval '12 hours'),
(9,7,20000,'kzt',1,20000,'transfer','completed','подарок', now() - interval '30 minutes'),
(6,10,10000,'rub',5.5,55000,'transfer','completed','оплата', now() - interval '20 days'),
(1,9,30000,'kzt',1,30000,'transfer','completed','перевод', now() - interval '5 hours'),
(8,2,200,'usd',470.5,94100,'deposit','completed','вклад', now() - interval '1 hour');


insert into audit_log(table_name, record_id, action, old_values, new_values, changed_by) values
('accounts', 1, 'insert', null, jsonb_build_object('account_number','kz01-0001','balance',500000), 'system'),
('transactions', 1, 'insert', null, jsonb_build_object('amount',50000,'from','kz01-0001'), 'system'),
('customers', 1, 'insert', null, jsonb_build_object('iin','870101123456'), 'system'),
('transactions', 3, 'insert', null, jsonb_build_object('amount',100,'currency','usd'), 'system'),
('transactions', 7, 'insert', null, jsonb_build_object('amount',20000), 'system'),
('accounts', 10, 'insert', null, jsonb_build_object('account_number','kz10-0010','balance',600000), 'system'),
('transactions', 10, 'insert', null, jsonb_build_object('amount',200,'currency','usd'), 'system'),
('exchange_rates', 1, 'insert', null, jsonb_build_object('from','usd','rate',470.5), 'system'),
('transactions', 4, 'insert', null, jsonb_build_object('amount',150000), 'system'),
('transactions', 2, 'insert', null, jsonb_build_object('amount',100000), 'system');

-- task 1:
create or replace procedure process_transfer(
    from_account_number text,
    to_account_number text,
    amount numeric,
    currency text,
    description text
)
language plpgsql
as $$
declare
    jz_acc_from accounts;
    jz_acc_to accounts;
    jz_cust customers;
    jz_rate numeric := 1;
    jz_amount_kzt numeric := 0;
    jz_daily_sum numeric := 0;
    jz_sp text := 'sp_transfer';
begin
    select * into jz_acc_from from accounts where account_number = from_account_number for update;
    if not found then
        insert into audit_log(table_name, record_id, action, new_values, changed_by)
            values('accounts', null, 'failed_transfer_source_missing', jsonb_build_object('from', from_account_number, 'amount', amount), current_user);
        raise exception 'err_404_source_account_not_found' using sqlstate='P0001';
    end if;

    select * into jz_acc_to from accounts where account_number = to_account_number for update;
    if not found then
        insert into audit_log(table_name, record_id, action, new_values, changed_by)
            values('accounts', null, 'failed_transfer_dest_missing', jsonb_build_object('to', to_account_number, 'amount', amount), current_user);
        raise exception 'err_404_dest_account_not_found' using sqlstate='P0002';
    end if;

    if not jz_acc_from.is_active then
        raise exception 'err_403_source_inactive' using sqlstate='P0003';
    end if;

    if not jz_acc_to.is_active then
        raise exception 'err_403_dest_inactive' using sqlstate='P0004';
    end if;

    select * into jz_cust from customers where customer_id = jz_acc_from.customer_id;
    if jz_cust.status <> 'active' then
        insert into audit_log(table_name, record_id, action, new_values, changed_by)
            values('customers', jz_cust.customer_id, 'failed_transfer_customer_inactive', jsonb_build_object('status', jz_cust.status), current_user);
        raise exception 'err_401_customer_not_active' using sqlstate='P0005';
    end if;

    -- conversion
    if lower(jz_acc_from.currency) = lower(currency) and lower(currency) = 'kzt' then
        jz_rate := 1;
        jz_amount_kzt := amount;
    else
        select rate into jz_rate
        from exchange_rates
        where from_currency = upper(currency) and to_currency = 'kzt'
        order by valid_from desc
        limit 1;
        if not found then
            insert into audit_log(table_name, record_id, action, new_values, changed_by)
                values('exchange_rates', null, 'missing_rate', jsonb_build_object('currency', currency), current_user);
            raise exception 'err_500_exchange_rate_missing' using sqlstate='P0006';
        end if;
        jz_amount_kzt := round(amount * jz_rate,2);
    end if;

    -- daily limit check
    select coalesce(sum(amount_kzt),0) into jz_daily_sum
    from transactions
    where from_account_id = jz_acc_from.account_id
      and created_at::date = now()::date;

    if jz_daily_sum + jz_amount_kzt > jz_cust.daily_limit_kzt then
        insert into audit_log(table_name, record_id, action, new_values, changed_by)
            values('transactions', null, 'daily_limit_exceeded', jsonb_build_object('requested_kzt', jz_amount_kzt,'daily_sum', jz_daily_sum,'limit', jz_cust.daily_limit_kzt), current_user);
        raise exception 'err_402_daily_limit_exceeded' using sqlstate='P0007';
    end if;

    -- balance check (account currency amounts)
    if jz_acc_from.balance < amount then
        insert into audit_log(table_name, record_id, action, old_values, new_values, changed_by)
            values('accounts', jz_acc_from.account_id, 'insufficient_funds', jsonb_build_object('balance', jz_acc_from.balance), jsonb_build_object('attempt', amount), current_user);
        raise exception 'err_400_insufficient_funds' using sqlstate='P0008';
    end if;

    execute 'savepoint ' || jz_sp;
    begin
        update accounts set balance = balance - amount where account_id = jz_acc_from.account_id;
        update accounts set balance = balance + amount where account_id = jz_acc_to.account_id;

        insert into transactions(from_account_id,to_account_id,amount,currency,exchange_rate,amount_kzt,type,status,description)
            values(jz_acc_from.account_id, jz_acc_to.account_id, amount, lower(currency), jz_rate, jz_amount_kzt, 'transfer', 'completed', description)
            returning transaction_id into jz_acc_from.account_id;            -- временное reuse переменной

        insert into audit_log(table_name, record_id, action, new_values, changed_by)
            values('transactions', currval('transactions_transaction_id_seq'), 'insert', jsonb_build_object('from', from_account_number, 'to', to_account_number, 'amount', amount, 'currency', currency), current_user);
    exception when others then
        execute 'rollback to savepoint ' || jz_sp;
        insert into audit_log(table_name, record_id, action, new_values, changed_by)
            values('transactions', null, 'failed_transfer_exception', jsonb_build_object('error', sqlerrm, 'from', from_account_number, 'to', to_account_number, 'amount', amount), current_user);
        raise;
    end;
end;
$$;

-- task 2: views
create view customer_balance_summary as
select
    c.customer_id,
    c.full_name,
    a.account_number,
    a.currency,
    a.balance,
    sum(
        a.balance * coalesce((select rate from exchange_rates er where er.from_currency = upper(a.currency) and er.to_currency = 'kzt' order by er.valid_from desc limit 1),1)
    ) over (partition by c.customer_id) as total_kzt,
    100 * (
        sum(a.balance * coalesce((select rate from exchange_rates er where er.from_currency = upper(a.currency) and er.to_currency = 'kzt' order by er.valid_from desc limit 1),1)) over (partition by c.customer_id)
    ) / nullif(c.daily_limit_kzt,0) as limit_utilization_pct,
    rank() over (order by sum(a.balance) over (partition by c.customer_id) desc) as rank_by_balance
from customers c
join accounts a on a.customer_id = c.customer_id;

create view daily_transaction_report as
select
    date(t.created_at) as tx_date,
    t.type,
    count(*) as tx_count,
    sum(t.amount_kzt) as total_volume_kzt,
    avg(t.amount_kzt) as avg_amount_kzt,
    sum(sum(t.amount_kzt)) over (order by date(t.created_at)) as running_total_kzt,
    case when lag(sum(t.amount_kzt)) over (order by date(t.created_at)) is null then null
         else 100 * (sum(t.amount_kzt) - lag(sum(t.amount_kzt)) over (order by date(t.created_at))) / nullif(lag(sum(t.amount_kzt)) over (order by date(t.created_at)),0)
    end as day_over_day_growth_pct
from transactions t
group by date(t.created_at), t.type;

create view suspicious_activity_view with (security_barrier=true) as
select t.*
from transactions t
where t.amount_kzt > 5000000
   or (
       select count(*) from transactions t2
       where t2.from_account_id = t.from_account_id
         and t2.created_at between t.created_at - interval '1 hour' and t.created_at + interval '1 hour'
   ) > 10
   or exists (
       select 1 from transactions t3
       where t3.from_account_id = t.from_account_id
         and t3.created_at between t.created_at - interval '1 minute' and t.created_at
         and t3.transaction_id <> t.transaction_id
   );

-- task 3:
create index idx_accounts_customer on accounts(customer_id);                        -- b-tree
create index idx_customers_email_expr on customers(lower(email));                   -- expression
create index idx_active_accounts_partial on accounts(account_id) where is_active;    -- partial
create index idx_tx_from_date_composite on transactions(from_account_id, created_at); -- composite
create index idx_audit_log_new_values_gin on audit_log using gin(new_values);       -- gin

-- покрывающий индекс
-- note: include(...) syntax supported in pg12+ (if not supported, remove include)
create index if not exists idx_tx_covering_from_acc_recent on transactions(from_account_id, created_at desc) include (amount_kzt, status, transaction_id);

-- brin  для больших временных сканов
create index if not exists idx_tx_created_at_brin on transactions using brin(created_at);

-- trigram for text similarity (install ext)
create extension if not exists pg_trgm;
create index if not exists idx_tx_description_trgm on transactions using gin (description gin_trgm_ops);

-- task 3: explain analyze scripts 
-- пример 1: частый запрос — последние транзакции по счёту
explain (analyze, buffers, format text)
select transaction_id, from_account_id, created_at, amount_kzt, status
from transactions
where from_account_id = (select account_id from accounts where account_number = 'kz01-0001' limit 1)
order by created_at desc
limit 20;

-- пример 2: поиск по email (expression)
explain (analyze, buffers, format text)
select customer_id, full_name, email from customers where lower(email) = 'alina.e@example.com';

-- пример 3: jsonb поиск (gin)
explain (analyze, buffers, format text)
select log_id, table_name, new_values from audit_log where new_values @> '{"account_number": "kz01-0001"}';

-- пример 4: range scan по дате (brin)
explain (analyze, buffers, format text)
select count(*) from transactions where created_at between now() - interval '90 days' and now();

-- пример 5: trigram search
explain (analyze, buffers, format text)
select transaction_id, description from transactions where description ilike '%зарплата%' limit 100;

-- task 4:

create or replace procedure process_salary_batch(
    company_account_number text,
    payments jsonb      -- формат: [{ "iin": "...", "amount": 1000, "description": "..." }, ...]
)
language plpgsql
as $$
declare
    jz_comp accounts;
    jz_total numeric := 0;
    jz_item jsonb;
    jz_success int := 0;
    jz_failed int := 0;
    jz_failed_details jsonb := '[]'::jsonb;
    jz_lock bigint;
    jz_target_acc text;
begin
    jz_lock := hashtext(company_account_number);
    perform pg_advisory_lock(jz_lock);

    select * into jz_comp from accounts where account_number = company_account_number for update;
    if not found then
        perform pg_advisory_unlock(jz_lock);
        raise exception 'err_company_account_not_found' using sqlstate='P0020';
    end if;

    for jz_item in select * from jsonb_array_elements(payments)
    loop
        jz_total := jz_total + (jz_item->>'amount')::numeric;
    end loop;

    if jz_comp.balance < jz_total then
        perform pg_advisory_unlock(jz_lock);
        raise exception 'err_company_insufficient_balance' using sqlstate='P0021';
    end if;

    -- process each payment, bypass daily limit (salary exception)
    for jz_item in select * from jsonb_array_elements(payments)
    loop
        begin
            savepoint sp_salary;
            -- find recipient account by iin (first active)
            select a.account_number into jz_target_acc
            from accounts a join customers c on a.customer_id = c.customer_id
            where c.iin = jz_item->>'iin' and a.is_active = true
            limit 1;

            if jz_target_acc is null then
                raise exception 'err_recipient_account_not_found';
            end if;

            -- call process_transfer but we need a special path that bypasses daily limit:
            -- implement transfer logic inline to bypass limit and use savepoint to continue on error

            -- get accounts locked
            perform 1;
            -- lock rows
            select * into jz_comp from accounts where account_number = company_account_number for update; -- company locked earlier
            -- lock recipient
            perform 1;
            -- use same logic as process_transfer but skip daily limit check
            -- fetch recipient account row
            declare local_from accounts; local_to accounts; local_rate numeric := 1; local_amount_kzt numeric := 0;
            begin
                select * into local_from from accounts where account_number = company_account_number for update;
                select * into local_to from accounts where account_number = jz_target_acc for update;

                if local_from.balance < (jz_item->>'amount')::numeric then
                    raise exception 'err_insufficient_company_funds';
                end if;

                if lower(local_from.currency) = 'kzt' then
                    local_rate := 1;
                    local_amount_kzt := (jz_item->>'amount')::numeric;
                else
                    select rate into local_rate from exchange_rates where from_currency = upper(local_from.currency) and to_currency = 'kzt' order by valid_from desc limit 1;
                    if not found then local_rate := 1; end if;
                    local_amount_kzt := round((jz_item->>'amount')::numeric * local_rate,2);
                end if;

                update accounts set balance = balance - (jz_item->>'amount')::numeric where account_id = local_from.account_id;
                update accounts set balance = balance + (jz_item->>'amount')::numeric where account_id = local_to.account_id;

                insert into transactions(from_account_id,to_account_id,amount,currency,exchange_rate,amount_kzt,type,status,description)
                    values(local_from.account_id, local_to.account_id, (jz_item->>'amount')::numeric, lower(local_from.currency), local_rate, local_amount_kzt, 'salary', 'completed', jz_item->>'description');

                jz_success := jz_success + 1;
            exception when others then
                rollback to savepoint sp_salary;
                jz_failed := jz_failed + 1;
                jz_failed_details := jz_failed_details || jsonb_build_object('iin', jz_item->>'iin', 'amount', jz_item->>'amount', 'error', sqlerrm);
            end;
        exception when others then
            rollback to savepoint sp_salary;
            jz_failed := jz_failed + 1;
            jz_failed_details := jz_failed_details || jsonb_build_object('iin', jz_item->>'iin', 'amount', jz_item->>'amount', 'error', sqlerrm);
        end;
    end loop;

    perform pg_advisory_unlock(jz_lock);

    -- save summary to materialized view (refresh pattern)
    refresh materialized view concurrently salary_batch_summary;

    raise notice 'salary batch completed: success=%, failed=%, details=%', jz_success, jz_failed, jz_failed_details;
end;
$$;

-- materialized view для отчёта батчей 
create materialized view if not exists salary_batch_summary as
select
    now() as generated_at,
    null::text as company_account,
    0::integer as successful_count,
    0::integer as failed_count,
    '[]'::jsonb as failed_details
with no data;

-- task 3: explain analyze 
-- перед созданием индексов: выполнить vacuum analyze
vacuum analyze transactions;
vacuum analyze accounts;
vacuum analyze customers;
vacuum analyze audit_log;

-- vacuum analyze после создания индексов
vacuum analyze transactions;
vacuum analyze accounts;
vacuum analyze customers;
vacuum analyze audit_log;


call process_transfer('kz01-0001','kz05-0005',10000,'kzt','тест успешный перевод');

-- недостаточно средств
begin;
    call process_transfer('kz03-0003','kz05-0005',1000000,'kzt','тест недостаточно');
exception when others then
    rollback;
end;

-- счёт назначения отсутствует
begin;
    call process_transfer('kz01-0001','kz99-9999',1000,'kzt','тест нет назначения');
exception when others then
    rollback;
end;

-- клиент заблокирован (iin из customers где status != active)
begin;
    call process_transfer('kz03-0003','kz01-0001',100,'kzt','тест блок клиент');
exception when others then
    rollback;
end;

-- превышение дневного лимита (сгенерировать множеством транзакций и повторить)
-- примерный сценарий: вставить много small переводов от одного аккаунта, затем вызвать transfer, чтобы сработал лимит.

-- тест process_salary_batch
select jsonb_agg(jsonb_build_object('iin', c.iin, 'amount', case when c.customer_id = 1 then 50000 else 1000 end, 'description', 'зарплата')) into temp payments_json
from customers c
limit 5;

call process_salary_batch('kz10-0010', '[{"iin":"870101123456","amount":50000,"description":"зарплата январь"},{"iin":"900202234567","amount":20000,"description":"зарплата январь"},{"iin":"930707707707","amount":10000,"description":"зарплата январь"}]'::jsonb);

-- concurrency demo 

-- 1  открыть psql session a: begin; select * from accounts where account_number='kz01-0001' for update;
-- 2 оставить транзакцию открытой
-- 3 в psql session b: попытаться выполнить call process_transfer('kz01-0001', 'kz05-0005', 1000, 'kzt', 'concurrency test');
-- ожидается, что session b будет ждать или получить блокировку до завершения session a; затем commit/rollback в session a и наблюдать поведение.




