package kr.namgim.namgim_eopsi

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundReceiver
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class NamgimWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.namgim_widget)
            bindLaunch(context, views)
            if (!widgetData.getString("summary", null).isNullOrEmpty()) {
                bindContent(context, views, widgetData)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun bindLaunch(context: Context, views: RemoteViews) {
        val openHome = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("namgim://home"),
        )
        views.setOnClickPendingIntent(R.id.widget_root, openHome)
        views.setOnClickPendingIntent(R.id.widget_header, openHome)
        views.setOnClickPendingIntent(R.id.widget_title, openHome)

        val openAdd = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("namgim://add"),
        )
        views.setOnClickPendingIntent(R.id.widget_add, openAdd)
        views.setContentDescription(R.id.widget_add, "재료 추가")
    }

    private fun bindContent(
        context: Context,
        views: RemoteViews,
        widgetData: SharedPreferences,
    ) {
        views.setTextViewText(R.id.widget_summary, widgetData.getString("summary", ""))
        views.setTextViewText(R.id.widget_detail, widgetData.getString("detail", ""))
        views.setViewVisibility(R.id.widget_empty, View.GONE)

        bindImminent(views, widgetData, 1, R.id.item_row_1, R.id.item1_name, R.id.item1_badge)
        bindImminent(views, widgetData, 2, R.id.item_row_2, R.id.item2_name, R.id.item2_badge)
        bindImminent(views, widgetData, 3, R.id.item_row_3, R.id.item3_name, R.id.item3_badge)

        val favoriteCount = widgetData.getString("favorite_count", "0")?.toIntOrNull() ?: 0
        views.setTextViewText(
            R.id.widget_favorites_label,
            widgetData.getString("favorites_label", "즐겨찾기"),
        )
        val hint = widgetData.getString("favorites_hint", "").orEmpty()
        if (favoriteCount == 0 || hint.isNotEmpty()) {
            views.setViewVisibility(R.id.widget_favorites_hint, View.VISIBLE)
            views.setTextViewText(R.id.widget_favorites_hint, hint)
        } else {
            views.setViewVisibility(R.id.widget_favorites_hint, View.GONE)
        }

        bindFavorite(context, views, widgetData, 1, R.id.fav1)
        bindFavorite(context, views, widgetData, 2, R.id.fav2)
        bindFavorite(context, views, widgetData, 3, R.id.fav3)
        bindFavorite(context, views, widgetData, 4, R.id.fav4)
    }

    private fun bindImminent(
        views: RemoteViews,
        widgetData: SharedPreferences,
        slot: Int,
        rowId: Int,
        nameId: Int,
        badgeId: Int,
    ) {
        val name = widgetData.getString("item${slot}_name", "").orEmpty()
        if (name.isEmpty()) {
            views.setViewVisibility(rowId, View.GONE)
            return
        }
        views.setViewVisibility(rowId, View.VISIBLE)
        views.setTextViewText(nameId, name)
        views.setTextViewText(badgeId, widgetData.getString("item${slot}_badge", ""))
        views.setTextColor(badgeId, badgeColor(widgetData.getString("item${slot}_tone", "")))
    }

    private fun bindFavorite(
        context: Context,
        views: RemoteViews,
        widgetData: SharedPreferences,
        slot: Int,
        viewId: Int,
    ) {
        val name = widgetData.getString("fav${slot}_name", "").orEmpty()
        val id = widgetData.getString("fav${slot}_id", "").orEmpty()
        if (name.isEmpty() || id.isEmpty()) {
            views.setViewVisibility(viewId, View.GONE)
            return
        }
        views.setViewVisibility(viewId, View.VISIBLE)
        views.setTextViewText(viewId, name)
        views.setContentDescription(viewId, "$name 담기")
        views.setOnClickPendingIntent(
            viewId,
            favoriteIntent(context, id, requestCode = 4100 + slot),
        )
    }

    private fun favoriteIntent(context: Context, id: String, requestCode: Int): PendingIntent {
        val intent = Intent(context, HomeWidgetBackgroundReceiver::class.java).apply {
            action = "es.antonborri.home_widget.action.BACKGROUND"
            data = Uri.parse("namgim://favorite?id=$id")
        }
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        return PendingIntent.getBroadcast(context, requestCode, intent, flags)
    }

    private fun badgeColor(tone: String?): Int {
        return when (tone) {
            "overdue" -> Color.parseColor("#B42318")
            "today" -> Color.parseColor("#FE8D47")
            "soon" -> Color.parseColor("#C47B12")
            else -> Color.parseColor("#345017")
        }
    }
}
