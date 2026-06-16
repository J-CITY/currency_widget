package com.example.currency_widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import org.json.JSONArray
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class CurrencyWidgetProvider : HomeWidgetProvider() {

    companion object {
        const val ACTION_REFRESH = "com.example.currency_widget.ACTION_REFRESH"
        val AVAILABLE_CURRENCY_ICONS = setOf("RUB", "USD", "CNY", 
            "EUR", "KZT", "JPY",
            "BYN", "UZS", "TRY", 
            "BTC")
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_REFRESH) {
            val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            prefs.edit().putBoolean("is_updating", true).apply()
            
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = android.content.ComponentName(context, CurrencyWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            
            appWidgetIds.forEach { widgetId ->
                updateWidget(context, appWidgetManager, widgetId, prefs)
            }
            
            val bgIntent = Intent(context, es.antonborri.home_widget.HomeWidgetBackgroundReceiver::class.java).apply {
                action = "es.antonborri.home_widget.action.BACKGROUND"
                data = Uri.parse("myAppWidget://update")
            }
            es.antonborri.home_widget.HomeWidgetBackgroundService.enqueueWork(context, bgIntent)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle?
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        val widgetData = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        updateWidget(context, appWidgetManager, appWidgetId, widgetData)
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            updateWidget(context, appWidgetManager, widgetId, widgetData)
        }
    }

    private fun getCurrencySymbol(code: String): String {
        return when (code.uppercase()) {
            "USD" -> "$"
            "EUR" -> "€"
            "RUB" -> "₽"
            "GBP" -> "£"
            "JPY" -> "¥"
            "CNY" -> "¥"
            "KRW" -> "₩"
            "INR" -> "₹"
            "BRL" -> "R$"
            "TRY" -> "₺"
            "KZT" -> "₸"
            else -> code
        }
    }

    private fun updateWidget(context: Context, appWidgetManager: AppWidgetManager, widgetId: Int, widgetData: SharedPreferences) {
        val options = appWidgetManager.getAppWidgetOptions(widgetId)
        val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)
        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)

        // Если высота меньше 100dp, считаем это "Высота 1" (обычно 40-70dp)
        val isSmallHeight = minHeight in 1..99
        val isNarrow = minWidth in 1..230
        val isWide = minWidth > 200
        
        val layoutId = if (isSmallHeight) R.layout.widget_layout_small else R.layout.widget_layout
        
        val views = RemoteViews(context.packageName, layoutId).apply {
            
            val title = widgetData.getString("title", context.getString(R.string.widget_title))
            val emptyMsg = widgetData.getString("empty_message", context.getString(R.string.widget_empty_message))
            val theme = widgetData.getString("widget_theme", "system")
            
            val isSystemDark = (context.resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK) == android.content.res.Configuration.UI_MODE_NIGHT_YES
            val isLight = if (theme == "system") !isSystemDark else theme == "light"
            var primaryTextColor = if (isLight) Color.BLACK else Color.WHITE
            var secondaryTextColor = if (isLight) Color.DKGRAY else Color.parseColor("#AAAAAA")
            var bgColor = if (isLight) Color.parseColor("#F5F5F5") else Color.parseColor("#212121")

            if (theme == "custom") {
                bgColor = Color.parseColor(widgetData.getString("custom_bg", "#212121"))
                primaryTextColor = Color.parseColor(widgetData.getString("custom_primary", "#FFFFFF"))
                secondaryTextColor = Color.parseColor(widgetData.getString("custom_secondary", "#AAAAAA"))
            }

            val titleStr = widgetData.getString("title", context.getString(R.string.widget_title))
            setTextViewText(R.id.tv_title, titleStr)
            
            val updateTimeStr = widgetData.getString("update_time", null)
            val isUpdating = widgetData.getBoolean("is_updating", false)
            
            if (isUpdating) {
                setTextViewText(R.id.tv_update_time, context.getString(R.string.widget_updating))
            } else if (updateTimeStr != null) {
                setTextViewText(R.id.tv_update_time, context.getString(R.string.widget_updated, updateTimeStr))
            } else {
                setTextViewText(R.id.tv_update_time, context.getString(R.string.widget_updated_empty))
            }

            if (!isSmallHeight) {
                setTextColor(R.id.tv_title, primaryTextColor)
                setTextColor(R.id.tv_update_time, secondaryTextColor)
                setTextColor(R.id.tv_empty, secondaryTextColor)
            }
            
            setTextColor(R.id.btn_refresh, primaryTextColor)

            if (theme != "system") {
                setInt(R.id.widget_root, "setBackgroundColor", bgColor)
            }

            removeAllViews(R.id.ll_rates_container)

            try {
                val ratesJson = widgetData.getString("rates_data", "[]")
                val jsonArray = JSONArray(ratesJson)
                
                // Для маленького макета выводим максимум 2 валюты (или больше, если широкий)
                val limit = if (isSmallHeight && !isWide) 2 else if (isSmallHeight) 3 else jsonArray.length()
                val itemsCount = Math.min(jsonArray.length(), limit)
                
                if (itemsCount == 0 && !isSmallHeight) {
                    val emptyView = RemoteViews(context.packageName, R.layout.widget_empty)
                    emptyView.setTextViewText(R.id.tv_empty_text, emptyMsg)
                    emptyView.setTextColor(R.id.tv_empty_text, secondaryTextColor)
                    addView(R.id.ll_rates_container, emptyView)
                } else {
                    for (i in 0 until itemsCount) {
                        val rateObj = jsonArray.getJSONObject(i)
                        val base = rateObj.getString("baseCurrency").uppercase()
                        val target = rateObj.getString("targetCurrency").uppercase()
                        val hasError = rateObj.optBoolean("hasError", false)
                        
                        val rowLayoutId = if (isSmallHeight) {
                            if (isWide) R.layout.widget_row_small_wide else R.layout.widget_row_small
                        } else {
                            if (isNarrow) R.layout.widget_row_narrow else R.layout.widget_row
                        }
                        
                        val rowView = RemoteViews(context.packageName, rowLayoutId)
                        val targetSymbol = getCurrencySymbol(target)
                        
                        rowView.setTextViewText(R.id.tv_currency_code, base)
                        rowView.setTextColor(R.id.tv_currency_code, primaryTextColor)
                        rowView.setTextColor(R.id.tv_rate, primaryTextColor)
                        
                        if (!isSmallHeight) {
                            if (AVAILABLE_CURRENCY_ICONS.contains(base)) {
                                val assetPath = "flutter_assets/assets/icon/${base}.png"
                                val inputStream = context.assets.open(assetPath)
                                val bitmap = android.graphics.BitmapFactory.decodeStream(inputStream)
                                rowView.setImageViewBitmap(R.id.iv_icon, bitmap)
                                rowView.setViewVisibility(R.id.iv_icon, android.view.View.VISIBLE)
                                rowView.setViewVisibility(R.id.tv_icon, android.view.View.GONE)
                                inputStream.close()
                            } else {
                                val flagText = if (base.length >= 2) base.substring(0, 2) else base
                                rowView.setTextViewText(R.id.tv_icon, flagText)
                                rowView.setTextColor(R.id.tv_icon, primaryTextColor)
                                rowView.setViewVisibility(R.id.iv_icon, android.view.View.GONE)
                                rowView.setViewVisibility(R.id.tv_icon, android.view.View.VISIBLE)
                            }
                        }
                        
                        if (isSmallHeight && isWide && i == itemsCount - 1) {
                            rowView.setViewVisibility(R.id.separator, android.view.View.GONE)
                        }
                        
                        if (!isSmallHeight && i == itemsCount - 1) {
                            rowView.setViewVisibility(R.id.row_separator, android.view.View.GONE)
                        }
                        
                        if (hasError) {
                            rowView.setTextViewText(R.id.tv_rate, "Error")
                            rowView.setTextViewText(R.id.tv_diff, "")
                        } else {
                            val rate = rateObj.getDouble("rate")
                            val prevRate = if (rateObj.has("previousRate") && !rateObj.isNull("previousRate")) rateObj.getDouble("previousRate") else rate
                            
                            val formattedRate = if (rate > 10000) {
                                String.format(Locale.US, "%.0f", rate)
                            } else if (rate > 100) {
                                String.format(Locale.US, "%.2f", rate)
                            } else {
                                String.format(Locale.US, "%.4f", rate)
                            }
                            
                            val rateStr = "$formattedRate $targetSymbol"
                            rowView.setTextViewText(R.id.tv_rate, rateStr)
                            
                            val diff = rate - prevRate
                            if (Math.abs(diff) > 0.00001) {
                                val symbol = if (diff > 0) "+" else ""
                                val arrow = if (diff > 0) "↗" else "↘"
                                val color = if (diff > 0) Color.parseColor("#4CAF50") else Color.parseColor("#F44336")
                                
                                val formattedDiff = if (Math.abs(diff) > 10000) {
                                    String.format(Locale.US, "%.0f", diff)
                                } else if (Math.abs(diff) > 100) {
                                    String.format(Locale.US, "%.2f", diff)
                                } else {
                                    String.format(Locale.US, "%.4f", diff)
                                }
                                
                                val diffText = if (isSmallHeight || isNarrow) arrow else "$symbol$formattedDiff $arrow"
                                rowView.setTextViewText(R.id.tv_diff, diffText)
                                rowView.setTextColor(R.id.tv_diff, color)
                            } else {
                                rowView.setTextViewText(R.id.tv_diff, "—")
                                rowView.setTextColor(R.id.tv_diff, secondaryTextColor)
                            }
                        }
                        
                        addView(R.id.ll_rates_container, rowView)
                    }
                }
            } catch (e: Exception) {
                if (!isSmallHeight) {
                    val errorView = RemoteViews(context.packageName, R.layout.widget_empty)
                    errorView.setTextViewText(R.id.tv_empty_text, "Widget Error: ${e.message}")
                    errorView.setTextColor(R.id.tv_empty_text, Color.RED)
                    addView(R.id.ll_rates_container, errorView)
                }
            }

            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            setOnClickPendingIntent(R.id.iv_app_icon, pendingIntent)

            val refreshIntent = Intent(context, CurrencyWidgetProvider::class.java).apply {
                action = ACTION_REFRESH
            }
            val pendingRefreshIntent = PendingIntent.getBroadcast(
                context, 0, refreshIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            setOnClickPendingIntent(R.id.btn_refresh, pendingRefreshIntent)
        }
        appWidgetManager.updateAppWidget(widgetId, views)
    }
}
