# Installation instructions #

Follow these steps to setup Flex-Spy in your Flex 3.0 application:

  * In Flex Builder, open the Properties window of your project (Project menu > Properties)
  * On the left side of the Properties window, select **Flex Library Build Path**.
  * On the right side of the Properties window, select the **Library path** tab.
  * Click the **Add SWC...** button
  * Select the flexspy.swc file that you downloaded (from the Downloads section) and click **OK**.
  * Add a button somewhere in your Flex application to show the Flex-Spy window:
```
<mx:Application xmlns:mx="http://www.adobe.com/2006/mxml">
  ...
  <mx:Script>
    <![CDATA[
      import com.flexspy.FlexSpy;
    ]]>
  </mx:Script>
  ...
  <mx:Button id="btnFlexSpy" label="FlexSpy" click="FlexSpy.show()" />
  ...
</mx:Application>
```