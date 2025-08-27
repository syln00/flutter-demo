现在添加一个查询订单并通知的需求，
当用户停留在通知tab页的时候，每30s查询一次https://www.shuguoren.com/tmh-dev/bapp-api/trade/order/newOrderCount?shopId=17接口，cookie中需要带上      {...options.headers,
      Authorization: `Bearer ${token}`},
接口返回的data中有这些字段orderCancelRequestCount: 0
orderDispatchCount: 0
orderPickUpCount: 0
saleUndisposedCount: 0，
只要有一个不为0就弹一个通知，并播放声音根目录下的newOrder.mp3,
并且这个tab页添加一个按钮可以立即发接口查询订单
当应用切到后台时，依然定时查询，如果有订单发通知并且播放声音