//+------------------------------------------------------------------+
//|                     ExpertMAPSARSizeOptimized.mq5               |
//|           Modifikasi: Menambahkan Take Profit (TP)              |
//+------------------------------------------------------------------+
#property copyright "Copyright 2000-2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.01"

//+------------------------------------------------------------------+
//| Include Files                                                   |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
#include <Expert\Signal\SignalMA.mqh>
#include <Expert\Trailing\TrailingParabolicSAR.mqh>
#include <Expert\Money\MoneySizeOptimized.mqh>

//+------------------------------------------------------------------+
//| Input Parameters                                                |
//+------------------------------------------------------------------+
input string             Inp_Expert_Title                 = "ExpertMAPSARSizeOptimized";
int                      Expert_MagicNumber               = 14598;
bool                     Expert_EveryTick                 = false;

//--- MA Signal Settings
input int                Inp_Signal_MA_Period             = 12;
input int                Inp_Signal_MA_Shift              = 6;
input ENUM_MA_METHOD     Inp_Signal_MA_Method             = MODE_SMA;
input ENUM_APPLIED_PRICE Inp_Signal_MA_Applied            = PRICE_CLOSE;

//--- Trailing Stop Settings (PSAR)
input double             Inp_Trailing_ParabolicSAR_Step   = 0.02;
input double             Inp_Trailing_ParabolicSAR_Maximum= 0.2;

//--- Take Profit Settings
input double             Inp_Take_Profit_Points           = 500; // TP dalam poin (50 pip)

//+------------------------------------------------------------------+
//| Expert Global Object                                            |
//+------------------------------------------------------------------+
CExpert ExtExpert;

//+------------------------------------------------------------------+
//| Initialization Function                                         |
//+------------------------------------------------------------------+
int OnInit()
{
   // Inisialisasi EA
   if (!ExtExpert.Init(Symbol(), Period(), Expert_EveryTick, Expert_MagicNumber))
   {
      printf(__FUNCTION__ + ": error initializing expert");
      ExtExpert.Deinit();
      return -1;
   }

   // Inisialisasi Sinyal (MA)
   CSignalMA *signal = new CSignalMA;
   if (signal == NULL)
   {
      printf(__FUNCTION__ + ": error creating signal");
      ExtExpert.Deinit();
      return -2;
   }
   if (!ExtExpert.InitSignal(signal))
   {
      printf(__FUNCTION__ + ": error initializing signal");
      ExtExpert.Deinit();
      return -3;
   }
   signal.PeriodMA(Inp_Signal_MA_Period);
   signal.Shift(Inp_Signal_MA_Shift);
   signal.Method(Inp_Signal_MA_Method);
   signal.Applied(Inp_Signal_MA_Applied);

   // Inisialisasi Trailing Stop (PSAR)
   CTrailingPSAR *trailing = new CTrailingPSAR;
   if (trailing == NULL)
   {
      printf(__FUNCTION__ + ": error creating trailing");
      ExtExpert.Deinit();
      return -5;
   }
   if (!ExtExpert.InitTrailing(trailing))
   {
      printf(__FUNCTION__ + ": error initializing trailing");
      ExtExpert.Deinit();
      return -6;
   }
   trailing.Step(Inp_Trailing_ParabolicSAR_Step);
   trailing.Maximum(Inp_Trailing_ParabolicSAR_Maximum);

   // Inisialisasi Money Management
   CMoneySizeOptimized *money = new CMoneySizeOptimized;
   if (money == NULL)
   {
      printf(__FUNCTION__ + ": error creating money");
      ExtExpert.Deinit();
      return -8;
   }
   if (!ExtExpert.InitMoney(money))
   {
      printf(__FUNCTION__ + ": error initializing money");
      ExtExpert.Deinit();
      return -9;
   }

   // Inisialisasi Indikator
   if (!ExtExpert.InitIndicators())
   {
      printf(__FUNCTION__ + ": error initializing indicators");
      ExtExpert.Deinit();
      return -11;
   }

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Function untuk Menempatkan Order dengan TP                      |
//+------------------------------------------------------------------+
bool PlaceOrder(int type, double lot)
{
   double price = (type == OP_BUY) ? Ask : Bid;
   double tp = (type == OP_BUY) ? price + Inp_Take_Profit_Points * Point : price - Inp_Take_Profit_Points * Point;

   int ticket = OrderSend(Symbol(), type, lot, price, 10, 0, tp, "MAPSAR Order", Expert_MagicNumber, 0, clrNONE);
   return (ticket > 0);
}

//+------------------------------------------------------------------+
//| Tick Event Handler                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   ExtExpert.OnTick();
}

//+------------------------------------------------------------------+
//| Trade Event Handler                                             |
//+------------------------------------------------------------------+
void OnTrade()
{
   ExtExpert.OnTrade();
}

//+------------------------------------------------------------------+
//| Timer Event Handler                                             |
//+------------------------------------------------------------------+
void OnTimer()
{
   ExtExpert.OnTimer();
}
