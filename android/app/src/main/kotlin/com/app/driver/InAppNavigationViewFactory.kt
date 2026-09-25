package com.app.driver

import android.app.Activity
import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class InAppNavigationViewFactory(
    private val messenger: BinaryMessenger,
    private val activity: Activity,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as? Map<*, *>
        return InAppNavigationView(context ?: activity, messenger, viewId, creationParams, activity)
    }
}
