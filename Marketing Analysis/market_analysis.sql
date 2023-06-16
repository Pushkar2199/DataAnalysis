use market_analysis;


/* 1. How many transactions were completed during each marketing campaign? */

select marketing_campaigns.campaign_name as campaign , count(*) as number_of_transactions  from transactions join marketing_campaigns 
on transactions.product_id = marketing_campaigns.product_id
group by marketing_campaigns.campaign_name order by number_of_transactions desc ; 





/*  2. Which product had the highest sales quantity? */

select sustainable_clothing.product_name as product_name , sum(transactions.quantity) as quantity from sustainable_clothing
join transactions on sustainable_clothing.product_id  = transactions.product_id 
group by product_name order by quantity desc ; 



/*	3. What is the total revenue generated from each marketing campaign?  */

select  marketing_campaigns.campaign_name as campaign , round(sum(sustainable_clothing.Price * transactions.quantity),2) as total_revenue
from   sustainable_clothing 
join transactions on sustainable_clothing.product_id = transactions.product_id 
join marketing_campaigns on marketing_campaigns.product_id = transactions.product_id 
group by campaign_name order by total_revenue desc ;


/*  4. What is the top-selling product category based on the total revenue generated?  */

select  sustainable_clothing.category  as top_category , round(sum(sustainable_clothing.Price * transactions.quantity),2) as total_revenue
from   sustainable_clothing 
join transactions on sustainable_clothing.product_id = transactions.product_id 
group by top_category order by total_revenue desc limit 1 ;



/* 5. Which products had a higher quantity sold compared to the average quantity sold?  */

select sustainable_clothing.product_name as product_name, SUM(transactions.quantity) as total_quantity
from transactions
join sustainable_clothing on transactions.product_id = sustainable_clothing.product_id
group by product_name
having SUM(transactions.quantity) > (select avg(quantity) from transactions)  
order by total_quantity desc;



/* 6. What is the average revenue generated per day during the marketing campaigns?  */


select x.campaign_name , round(avg(x.total_revenue),2) as avg_revenue 
from     (
			select marketing_campaigns.campaign_name as campaign_name , sum(sustainable_clothing.price * transactions.quantity) as total_revenue 
			from transactions 
			join  sustainable_clothing on  sustainable_clothing.product_id = transactions.product_id
			join  marketing_campaigns on  sustainable_clothing.product_id =  marketing_campaigns.product_id
			where transactions.purchase_date >= marketing_campaigns.start_date and transactions.purchase_date <= marketing_campaigns.end_date
			group by marketing_campaigns.campaign_name ,transactions.purchase_date 
		) as x
group by x.campaign_name;







/* 7. What is the percentage contribution of each product to the total revenue? */

select
    sc.product_name as product_name,
    ROUND(sc.price, 2) as price,
    ROUND(SUM(sc.price * t.quantity), 2) as revenue,
    ROUND((SUM(sc.price * t.quantity) / (select SUM(sc.price * t.quantity) from transactions as  t join sustainable_clothing as sc on t.product_id = sc.product_id)) * 100, 2) as revenue_contribution_percentage
from
    transactions as t
join
    sustainable_clothing as sc on t.product_id = sc.product_id
group by
    sc.product_name, sc.price  
order by   revenue_contribution_percentage desc ;




/* 8. Compare the average quantity sold during marketing campaigns to outside the marketing campaigns */

select case 
        when t.purchase_date between mc.start_date and mc.end_date then 'During Campaign'
        else 'Outside Campaign'
        end as  campaign_status,
    avg(t.quantity) as  average_quantity_sold
from transactions as  t 
join marketing_campaigns as mc on t.product_id = mc.product_id
group by  campaign_status;


/* 9. Compare the revenue generated by products inside the marketing campaigns to outside the campaigns  */

select 
    case
        when t.purchase_date between mc.start_date and mc.end_date then 'During Campaign'
        else 'Outside Campaign'
    end as  campaign_status,
    round(SUM(sc.price * t.quantity),2) as total_revenue
from 
    transactions as t
join 
    sustainable_clothing as sc on t.product_id = sc.product_id
left join marketing_campaigns as mc on t.product_id = mc.product_id
group by 
    campaign_status;






/*   10. Rank the products by their average daily quantity sold  */

select
    product_name,
    round(avg(quantity),2) as average_daily_quantity_sold,
    rank() over (order by avg(quantity) desc) as  product_rank
from transactions
join sustainable_clothing using (product_id)
group by product_id, product_name
order by average_daily_quantity_sold desc;

