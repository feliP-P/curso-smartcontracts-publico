// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/Alcancia.sol";

/// @dev ACTIVIDAD DE LA CLASE 3.
///      El primer test está resuelto como MODELO: mostrá cómo se ve un test
///      completo (arrange / act / assert) y de ahí en más van solos.
///      Los que siguen son consignas: hay que escribirlos.
contract AlcanciaTest is Test {
    Alcancia alcancia;
    address alice = makeAddr("alice");
    address bob   = makeAddr("bob");

    function setUp() public {
        alcancia = new Alcancia();      // el owner es este contrato de test
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }

    // =========================================================================
    // MODELO — este ya está resuelto. Miralo y usalo de plantilla.
    // =========================================================================

    function test_Ahorrar_AcreditaElAhorro() public {
        vm.prank(alice);
        alcancia.ahorrar{value: 1 ether}();

        vm.prank(alice);
        assertEq(alcancia.miAhorro(), 1 ether);
    }

    // =========================================================================
    // A ESCRIBIR — cada uno es una consigna. Borrá el `fail()` cuando lo hagas.
    // =========================================================================

    /// El caso feliz: alice ahorra 3 ETH, retira, y su ahorro queda en 0
    /// **y** el ETH volvió a su cuenta.
    function test_Retirar_DevuelveTodoElAhorro() public {
        vm.prank(alice);
        alcancia.ahorrar{value: 3 ether}();

        vm.prank(alice);
        alcancia.retirar();
        vm.prank(alice);
        assertEq(alcancia.miAhorro(), 0);
        assertEq(alice.balance, 10 ether);
    }

    /// Retirar sin haber ahorrado nada tiene que revertir con `SinAhorros`.
    /// Pista: `vm.expectRevert(Alcancia.SinAhorros.selector);`
    function test_Retirar_RevierteSinAhorros() public {
        vm.prank(bob);
        assertEq(alcancia.miAhorro(), 0);

        vm.expectRevert(Alcancia.SinAhorros.selector);
        vm.prank(bob);
        alcancia.retirar();
    }

    /// Lo que ahorró alice no puede afectar lo de bob.
    /// (Es el análogo del `test_BalancesAreIsolated` del Vault.)
    function test_AhorrosAisladosEntreUsuarios() public {
        vm.prank(alice);
        alcancia.ahorrar{value: 2 ether}();
        vm.prank(bob);
        alcancia.ahorrar{value: 5 ether}();
        vm.prank(alice);
        assertEq(alcancia.miAhorro(), 2 ether);
        vm.prank(bob);
        assertEq(alcancia.miAhorro(), 5 ether);
    }

    /// El comportamiento con la alcancía CERRADA.
    /// Ojo: este test depende de la decisión de diseño que hayas tomado en
    /// `retirar()`. Escribí el que corresponda a TU implementación y prepará
    /// el argumento de por qué elegiste eso.
    function test_Retirar_ConLaAlcanciaCerrada() public {
        vm.prank(alice);
        alcancia.ahorrar{value: 1 ether}();
        alcancia.cerrar();
        vm.expectEmit(true, true, false, true);
        emit Alcancia.Retiro(alice, 1 ether);
        vm.prank(alice);
        alcancia.retirar();
    }
}
