-- ==========================================
-- CASO 1: ANALISIS DE PROPIEDADES
-- ==========================================

SELECT
    p.id_tipo_propiedad AS "TIPO",
    COUNT(*) AS "TOTAL_PROPIEDADES",

    TO_CHAR(
        MAX(p.valor_arriendo),
        'FML999G999G999D00',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "MAX_ARRIENDO",

    TO_CHAR(
        ROUND(AVG(p.valor_arriendo)),
        'FML999G999G999',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "PROMEDIO_ARRIENDO",

    TO_CHAR(
        MIN(p.valor_arriendo),
        'FML999G999G999D00',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "MIN_ARRIENDO",

    CASE
        WHEN MAX(p.valor_arriendo) <= 1000000
            THEN 'ESTANDAR'
        ELSE 'PREMIUM'
    END AS "CLASIFICACION",

    TO_CHAR(
        NVL(SUM(p.valor_gasto_comun), 0),
        'FML999G999G999',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "TOTAL_GASTOS_COMUNES"

FROM propiedad p

GROUP BY p.id_tipo_propiedad

HAVING SUM(NVL(p.valor_gasto_comun, 0))
       > &VALOR_TOTAL_GASTO_COMUN

ORDER BY SUM(NVL(p.valor_gasto_comun, 0)) DESC;


-- ==========================================
-- CASO 2: ANTIGUEDAD DE EMPLEADOS
-- ==========================================

SELECT
    UPPER(e.nombre_emp || ' ' || e.appaterno_emp)
        AS "Nombre Empleado",

    TO_CHAR(
        e.sueldo_emp,
        'FML999G999G999',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "Sueldo con Formato",

    CASE
        WHEN e.sueldo_emp > 2000000 THEN 'ALTO'
        ELSE 'MEDIO'
    END AS "Clasificación Sueldo",

    TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12)
        AS "Años Antigüedad",

    'Corresponde bono ' ||
    CASE
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12)
             BETWEEN 5 AND 10 THEN '5%'
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12)
             BETWEEN 11 AND 20 THEN '10%'
        ELSE '15%'
    END || ': ' ||
    TO_CHAR(
        ROUND(
            e.sueldo_emp *
            CASE
                WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12)
                     BETWEEN 5 AND 10 THEN 0.05
                WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12)
                     BETWEEN 11 AND 20 THEN 0.10
                ELSE 0.15
            END
        ),
        'FML999G999G999',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "BONO"

FROM empleado e

WHERE e.id_categoria_emp = 3
  AND TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12) > 5
  AND e.id_sucursal <> &CODIGO_SUCURSAL

ORDER BY e.sueldo_emp DESC;

-- ==========================================
-- CASO 3: LISTADO DE CLIENTES
-- ==========================================

SELECT
    CASE
        WHEN renta_cli >= 1000000 THEN 'PREMIUM'
        WHEN renta_cli >= 600000 THEN 'ALTA'
        WHEN renta_cli >= 300000 THEN 'MEDIA'
        ELSE 'BAJA'
    END AS "CLASIFICACION_RENTA",

    COUNT(*) AS "CANTIDAD_CLIENTES",

    TO_CHAR(
        ROUND(AVG(renta_cli)),
        'FML999G999G999',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "RENTA_PROMEDIO",

    CASE
        WHEN COUNT(celular_cli) = 0
            THEN 'Clientes sin Teléfono'
        ELSE 'Clientes con Teléfono'
    END AS "ESTADO_TELEFONO"

FROM cliente

GROUP BY
    CASE
        WHEN renta_cli >= 1000000 THEN 'PREMIUM'
        WHEN renta_cli >= 600000 THEN 'ALTA'
        WHEN renta_cli >= 300000 THEN 'MEDIA'
        ELSE 'BAJA'
    END

HAVING AVG(renta_cli) > 200000

ORDER BY "CLASIFICACION_RENTA";
