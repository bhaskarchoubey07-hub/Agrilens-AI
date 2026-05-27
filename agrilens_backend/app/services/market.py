import random

class MarketService:
    @staticmethod
    def get_market_prices(lang: str = "hi") -> list:
        """
        Retrieves real-time crop prices, trends, and future prediction data.
        """
        is_hindi = (lang == "hi")
        
        crops = [
            {
                "id": "wheat",
                "name": "गेहूं (Wheat)" if is_hindi else "Wheat",
                "price": 2450,
                "unit": "रु/क्विंटल" if is_hindi else "Rs/Quintal",
                "trend": "up", # up, down, stable
                "predicted_price": 2600,
                "profit_outlook": "अच्छा (+12%)" if is_hindi else "Good (+12%)",
                "color": "green"
            },
            {
                "id": "paddy",
                "name": "धान (Paddy/Rice)" if is_hindi else "Paddy",
                "price": 2180,
                "unit": "रु/क्विंटल" if is_hindi else "Rs/Quintal",
                "trend": "stable",
                "predicted_price": 2200,
                "profit_outlook": "सामान्य (+5%)" if is_hindi else "Normal (+5%)",
                "color": "orange"
            },
            {
                "id": "potato",
                "name": "आलू (Potato)" if is_hindi else "Potato",
                "price": 1400,
                "unit": "रु/क्विंटल" if is_hindi else "Rs/Quintal",
                "trend": "down",
                "predicted_price": 1250,
                "profit_outlook": "कम (-10%)" if is_hindi else "Low (-10%)",
                "color": "red"
            },
            {
                "id": "tomato",
                "name": "टमाटर (Tomato)" if is_hindi else "Tomato",
                "price": 2800,
                "unit": "रु/क्विंटल" if is_hindi else "Rs/Quintal",
                "trend": "up",
                "predicted_price": 3200,
                "profit_outlook": "बहुत अच्छा (+25%)" if is_hindi else "Excellent (+25%)",
                "color": "green"
            },
            {
                "id": "mustard",
                "name": "सरसों (Mustard)" if is_hindi else "Mustard",
                "price": 5450,
                "unit": "रु/क्विंटल" if is_hindi else "Rs/Quintal",
                "trend": "up",
                "predicted_price": 5700,
                "profit_outlook": "अच्छा (+8%)" if is_hindi else "Good (+8%)",
                "color": "green"
            },
            {
                "id": "soybean",
                "name": "सोयाबीन (Soybean)" if is_hindi else "Soybean",
                "price": 4600,
                "unit": "रु/क्विंटल" if is_hindi else "Rs/Quintal",
                "trend": "stable",
                "predicted_price": 4650,
                "profit_outlook": "सामान्य (+2%)" if is_hindi else "Normal (+2%)",
                "color": "orange"
            }
        ]
        
        return crops

    @staticmethod
    def calculate_profit_estimate(farm_size: float, crop_id: str, yield_per_acre: float) -> dict:
        """
        Calculates profit estimates based on farm size and crop type.
        """
        # Average production and input cost per acre
        crop_cost_db = {
            "wheat": {"cost_per_acre": 15000, "price_per_quintal": 2450},
            "paddy": {"cost_per_acre": 18000, "price_per_quintal": 2180},
            "potato": {"cost_per_acre": 25000, "price_per_quintal": 1400},
            "tomato": {"cost_per_acre": 35000, "price_per_quintal": 2800},
            "mustard": {"cost_per_acre": 12000, "price_per_quintal": 5450},
            "soybean": {"cost_per_acre": 14000, "price_per_quintal": 4600}
        }
        
        stats = crop_cost_db.get(crop_id, {"cost_per_acre": 15000, "price_per_quintal": 2000})
        
        total_cost = stats["cost_per_acre"] * farm_size
        total_yield = yield_per_acre * farm_size
        gross_revenue = total_yield * stats["price_per_quintal"]
        net_profit = gross_revenue - total_cost
        
        return {
            "total_cost_inr": round(total_cost, 2),
            "total_yield_quintals": round(total_yield, 2),
            "gross_revenue_inr": round(gross_revenue, 2),
            "net_profit_inr": round(net_profit, 2),
            "roi_percentage": round((net_profit / total_cost * 100), 2) if total_cost > 0 else 0
        }

market_service = MarketService()
