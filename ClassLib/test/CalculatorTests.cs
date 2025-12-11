using NUnit.Framework;
using Calculator;

namespace TestCalculator;

[TestFixture]
public class CalculatorTests
{
    private Calculator.Calculator _calculator = null!;

    [SetUp]
    public void Setup()
    {
        _calculator = new Calculator.Calculator();
    }

    #region Add Tests

    [Test]
    public void Add_TwoPositiveNumbers_ReturnsCorrectSum()
    {
        // Arrange
        double a = 10;
        double b = 5;

        // Act
        var result = _calculator.Add(a, b);

        // Assert
        Assert.That(result, Is.EqualTo(15));
    }

    [Test]
    public void Add_TwoNegativeNumbers_ReturnsCorrectSum()
    {
        // Arrange
        double a = -10;
        double b = -5;

        // Act
        var result = _calculator.Add(a, b);

        // Assert
        Assert.That(result, Is.EqualTo(-15));
    }

    [Test]
    public void Add_PositiveAndNegativeNumber_ReturnsCorrectSum()
    {
        // Arrange
        double a = 10;
        double b = -5;

        // Act
        var result = _calculator.Add(a, b);

        // Assert
        Assert.That(result, Is.EqualTo(5));
    }

    #endregion

    #region Subtract Tests

    [Test]
    public void Subtract_TwoPositiveNumbers_ReturnsCorrectDifference()
    {
        // Arrange
        double a = 10;
        double b = 5;

        // Act
        var result = _calculator.Subtract(a, b);

        // Assert
        Assert.That(result, Is.EqualTo(5));
    }

    [Test]
    public void Subtract_TwoNegativeNumbers_ReturnsCorrectDifference()
    {
        // Arrange
        double a = -10;
        double b = -5;

        // Act
        var result = _calculator.Subtract(a, b);

        // Assert
        Assert.That(result, Is.EqualTo(-5));
    }

    #endregion

    #region Multiply Tests

    [Test]
    public void Multiply_TwoPositiveNumbers_ReturnsCorrectProduct()
    {
        // Arrange
        double a = 10;
        double b = 5;

        // Act
        var result = _calculator.Multiply(a, b);

        // Assert
        Assert.That(result, Is.EqualTo(50));
    }

    [Test]
    public void Multiply_WithZero_ReturnsZero()
    {
        // Arrange
        double a = 10;
        double b = 0;

        // Act
        var result = _calculator.Multiply(a, b);

        // Assert
        Assert.That(result, Is.EqualTo(0));
    }

    [Test]
    public void Multiply_TwoNegativeNumbers_ReturnsPositiveProduct()
    {
        // Arrange
        double a = -10;
        double b = -5;

        // Act
        var result = _calculator.Multiply(a, b);

        // Assert
        Assert.That(result, Is.EqualTo(50));
    }

    #endregion

    #region Divide Tests

    [Test]
    public void Divide_TwoPositiveNumbers_ReturnsCorrectQuotient()
    {
        // Arrange
        double a = 10;
        double b = 5;

        // Act
        var result = _calculator.Divide(a, b);

        // Assert
        Assert.That(result, Is.EqualTo(2));
    }

    [Test]
    public void Divide_ByZero_ThrowsDivideByZeroException()
    {
        // Arrange
        double a = 10;
        double b = 0;

        // Act & Assert
        Assert.Throws<DivideByZeroException>(() => _calculator.Divide(a, b));
    }

    [Test]
    public void Divide_ZeroByNumber_ReturnsZero()
    {
        // Arrange
        double a = 0;
        double b = 5;

        // Act
        var result = _calculator.Divide(a, b);

        // Assert
        Assert.That(result, Is.EqualTo(0));
    }

    #endregion
}

