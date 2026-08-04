import Combine
import SwiftlyTest
import Testing

@MainActor
struct TurbineTests {

  /// The minimal reproduction of the CI hang: `expectInitial` matching the current value used to spin
  /// instead of consuming it, so this test never reached `send(1)`.
  @Test
  func whenSubscribedBeforeAnyChange_initialIsConsumed() async {
    // given
    let subject = CurrentValueSubject<Int, Never>(0)

    await test(subject) { turbine in
      await turbine.expectInitial(value: 0)

      // when
      subject.send(1)

      // then
      let result = await turbine.value()
      #expect(result == 1)
    }
  }

  @Test
  func whenInitialWasMissed_firstValueIsPutBack() async {
    // given: the observed source already progressed past its initial value before we subscribed
    let subject = CurrentValueSubject<Int, Never>(5)

    await test(subject) { turbine in
      // when
      await turbine.expectInitial(value: 0)

      // then
      let result = await turbine.value()
      #expect(result == 5)
    }
  }

  @Test
  func valuesEmittedWhileNotAwaiting_areBufferedInOrder() async {
    // given
    let subject = CurrentValueSubject<Int, Never>(0)

    await test(subject) { turbine in
      await turbine.expectInitial(value: 0)

      // when
      subject.send(1)
      subject.send(2)

      // then
      let first = await turbine.value()
      let second = await turbine.value()
      #expect(first == 1)
      #expect(second == 2)
    }
  }

  @Test
  func whenValueArrivesWhileAwaiting_awaitResumesWithIt() async {
    // given
    let subject = CurrentValueSubject<Int, Never>(0)

    await test(subject) { turbine in
      await turbine.expectInitial(value: 0)

      // when: emitted only after value() below has suspended and freed the main actor
      Task {
        subject.send(7)
      }

      // then
      let result = await turbine.value()
      #expect(result == 7)
    }
  }
}
