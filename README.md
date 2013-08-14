JSIAPManager
============

A block-based In-App Purchase Manager to help make incorporating IAP a little bit easier!
------------

JSIAPManager is intended to be as simple to use as possible! In your AppDelegate, simply prime the pump by calling [JSIAPManager sharedManager]. This will register the manager as the SKPaymentQueue's transaction observer. Per Apple's recommendation, it's important that this is set in the AppDelegate in <pre><code>applicationDidFinishLaunchingWithOptions:</code></pre>.

After that, just add yor product identifiers to JSIAPManager.m and you're good to go!

Version 0.1
------------
Apple-hosted content still needs supporting. However, other IAP Methods are working!