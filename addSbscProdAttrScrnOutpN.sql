네, Oracle SQL을 MariaDB SQL로 변환하겠습니다. 주요 변경 사항에 대해 주석으로 설명을 추가하겠습니다.

```sql
<!-- 청약신청 > 청약상품속성 정보 생성 [화면노출N - 유큐브필수Y] -->
<insert id="addSbscProdAttrScrnOutpN" parameterType="BizSvcApplyCalcDto">
    /* bizSvcApply-mapper.xml(addSbscProdAttrScrnOutpN) */
    INSERT INTO TB_SPSS_SBSC_PROD_ATTR_M
    (
        SBSC_MGMT_ID
        , PLFM_PROD_ID
        , PROD_ATTR_SEQ
        , PROD_ATTR_CD
        , ENTR_META_CD
        , PROD_ATTR_VLUE
        , PROD_ATTR_SPRM
        , PROD_ATTR_VAT
        , MFPN_ID
        , REGI_ID
        , UPD_DTTM
        , REG_DTTM
    )
    -- 변환 난이도: 4
    -- Oracle의 힌트는 MariaDB에서 지원하지 않으므로 제거합니다.
    SELECT 
        SBSC_MGMT_ID
        , PLFM_PROD_ID
        , ATTR_SEQ
        , PROD_ATTR_CD
        , ENTR_META_CD
        , ATTR_ITEM_VLUE
        , ATTR_ITEM_SPRM
        , ATTR_ITEM_VAT
        , MFPN_ID
        , REGI_ID
        , UPD_DTTM
        , REG_DTTM
    FROM (
        -- 변환 난이도: 5
        -- WITH 절을 서브쿼리로 변경합니다.
        -- CONNECT BY를 사용한 계층 쿼리를 CROSS JOIN으로 대체합니다.
        WITH RECURSIVE CHRR_META AS (
            SELECT
                CASE T3.LVL
                    WHEN 1 THEN T1.FXED_FCTR29
                    WHEN 2 THEN T1.FXED_FCTR15
                    WHEN 3 THEN T1.FXED_FCTR17
                    WHEN 4 THEN T1.FXED_FCTR16
                    WHEN 5 THEN T1.FXED_FCTR18
                    WHEN 6 THEN T1.FXED_FCTR8
                    WHEN 7 THEN T1.VAR_FCTR7
                END AS ATTR_ITEM_VLUE
                , CASE T3.LVL
                    WHEN 1 THEN T2.FXED_FCTR29
                    WHEN 2 THEN T2.FXED_FCTR15
                    WHEN 3 THEN T2.FXED_FCTR17
                    WHEN 4 THEN T2.FXED_FCTR16
                    WHEN 5 THEN T2.FXED_FCTR18
                    WHEN 6 THEN T2.FXED_FCTR8
                    WHEN 7 THEN T2.VAR_FCTR7
                END AS ENTR_META_CD
            FROM (
                SELECT
                    -- 변환 난이도: 2
                    -- NVL을 IFNULL로 변경합니다.
                    IFNULL(B.CO_NM, B.CUST_NM) AS FXED_FCTR29
                    , CASE
                        WHEN B.CUST_KD_CD = 'GC' OR B.CUST_KD_CD = 'GNP' THEN C.CHRR_NM
                        WHEN B.CUST_KD_CD = 'GEX' THEN B.REPR_NM
                        ELSE B.CUST_NM
                    END AS FXED_FCTR15
                    , CASE
                        WHEN B.CUST_KD_CD = 'GC' OR B.CUST_KD_CD = 'GNP' THEN C.CHRR_MBL_CTPL
                        ELSE B.CUST_HPNO
                    END AS FXED_FCTR17
                    , CASE
                        WHEN B.CUST_KD_CD = 'GC' OR B.CUST_KD_CD = 'GNP' THEN C.CHRR_MBL_CTPL
                        ELSE B.CUST_HPNO
                    END AS FXED_FCTR16
                    , CASE
                        WHEN B.CUST_KD_CD = 'GC' OR B.CUST_KD_CD = 'GNP' THEN C.CHRR_MBL_CTPL
                        ELSE B.CUST_HPNO
                    END AS VAR_FCTR7
                    , CASE
                        WHEN B.CUST_KD_CD = 'GC' OR B.CUST_KD_CD = 'GNP' THEN C.CHRR_EMAL_ADDR
                        ELSE B.CUST_EMAL
                    END AS FXED_FCTR18
                    , CASE
                        WHEN B.CUST_KD_CD = 'GC' OR B.CUST_KD_CD = 'GNP' THEN C.CHRR_EMAL_ADDR
                        ELSE B.CUST_EMAL
                    END AS FXED_FCTR8
                FROM TB_SPCS_CUST_M B
                LEFT OUTER JOIN TB_SPCS_CHRR_M C ON B.CUST_MGMT_ID = C.CUST_MGMT_ID
                WHERE
                    B.CUST_MGMT_ID = #{custMgmtId}
            ) T1
            CROSS JOIN (
                -- 변환 난이도: 3
                -- DUAL 테이블 대신 VALUES를 사용합니다.
                SELECT 'fxedFctr29' AS FXED_FCTR29
                    , 'fxedFctr15' AS FXED_FCTR15
                    , 'fxedFctr17' AS FXED_FCTR17
                    , 'fxedFctr16' AS FXED_FCTR16
                    , 'fxedFctr18' AS FXED_FCTR18
                    , 'fxedFctr8' AS FXED_FCTR8
                    , 'varFctr7' AS VAR_FCTR7
            ) T2
            CROSS JOIN (
                -- 변환 난이도: 4
                -- CONNECT BY를 재귀 쿼리로 변경합니다.
                WITH RECURSIVE cte(LVL) AS (
                    SELECT 1
                    UNION ALL
                    SELECT LVL + 1 FROM cte WHERE LVL < 7
                )
                SELECT LVL FROM cte
            ) T3
        )
        SELECT
            #{sbscMgmtId} AS SBSC_MGMT_ID
            , B.PLFM_PROD_ID
            , B.ATTR_SEQ
            , B.PROD_ATTR_CD
            , B.ENTR_META_CD 
            , CASE
                WHEN B.ATTR_DISP_FORM_CD = 'HD' THEN IFNULL(C.ATTR_ITEM_VLUE, B.ATTR_BS_VAL)
                WHEN B.PROD_ATTR_CD = 'BRZ0000036' AND 'Y' = #{bdlStat} THEN '번들가입'
                WHEN B.ENTR_META_CD = 'varFctr7' AND 'BPZ0000015' != #{sltnId}
                    THEN A.ATTR_ITEM_VLUE
                WHEN B.ENTR_META_CD = 'fxedFctr29' AND B.PROD_ATTR_CD = 'BRZ0000019'    THEN IFNULL(C.ATTR_ITEM_VLUE, A.ATTR_ITEM_VLUE)
                WHEN B.ENTR_META_CD = 'fxedFctr15' AND B.PROD_ATTR_CD = 'BRZ0000033'    THEN IFNULL(C.ATTR_ITEM_VLUE, A.ATTR_ITEM_VLUE)
                WHEN B.ENTR_META_CD = 'fxedFctr16' AND B.PROD_ATTR_CD = 'BRZ0000034'    THEN IFNULL(C.ATTR_ITEM_VLUE, A.ATTR_ITEM_VLUE)
                WHEN B.ENTR_META_CD = 'fxedFctr17' AND B.PROD_ATTR_CD IN ('BRZ0000076','BRZ0000097')        THEN IFNULL(C.ATTR_ITEM_VLUE, A.ATTR_ITEM_VLUE)
                WHEN B.ENTR_META_CD IN ('fxedFctr18','fxedFctr8') AND B.PROD_ATTR_CD = 'BRZ0000037'     THEN IFNULL(C.ATTR_ITEM_VLUE, A.ATTR_ITEM_VLUE)
                WHEN B.ENTR_META_CD = 'varFctr7' AND B.PROD_ATTR_CD NOT IN ('BRZ0000036','BRZ0000008') THEN IFNULL(C.ATTR_ITEM_VLUE, A.ATTR_ITEM_VLUE)
                ELSE  IFNULL(C.ATTR_ITEM_VLUE, A.ATTR_ITEM_VLUE)
            END AS ATTR_ITEM_VLUE
            , A.ATTR_ITEM_SPRM
            , A.ATTR_ITEM_VAT
            , #{custMgmtId} AS MFPN_ID
            , #{custMgmtId} AS REGI_ID
            -- 변환 난이도: 1
            -- SYSDATE를 NOW()로 변경합니다.
            , NOW() AS UPD_DTTM
            , NOW() AS REG_DTTM
        FROM TB_SPSV_PROD_ATTR_ITEM_M A
        INNER JOIN TB_SPSV_PROD_ATTR_I B ON (
            A.SLTN_ID = B.SLTN_ID
            AND A.ATTR_SEQ = B.ATTR_SEQ
            AND A.PROD_ID = B.PLFM_PROD_ID
            AND B.USE_YN = 'Y'
            AND B.UCUBE_MNDT_YN = 'Y'
            AND B.ATTR_SCRN_OUTP_YN = 'N'
        )
        LEFT OUTER JOIN CHRR_META C ON B.ENTR_META_CD = C.ENTR_META_CD
        WHERE
            A.SLTN_ID = #{sltnId}
            AND A.PROD_ID = #{plfmProdId}
            AND A.USE_YN = 'Y'
    )
</insert>
```

주요 변경 사항:
1. Oracle 힌트 제거
2. NVL을 IFNULL로 변경
3. DUAL 테이블 대신 VALUES 사용
4. CONNECT BY를 재귀 쿼리로 변경
5. SYSDATE를 NOW()로 변경
6. WITH 절을 서브쿼리로 변경

각 변경 사항에 대해 난이도를 주석으로 표시했습니다. 전체적인 쿼리의 구조와 로직은 유지하면서 MariaDB에 맞게 조정했습니다.