네, Oracle SQL을 MariaDB SQL로 변환하겠습니다. 주요 변경사항과 함께 변환된 코드를 제공하겠습니다.

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
        -- 담당자 정보 조회 후 fxedFctr 설정
        WITH RECURSIVE CHRR_META AS (
            -- 변환 난이도: 4
            -- CONNECT BY를 RECURSIVE CTE로 변환
            SELECT 1 AS LVL
            UNION ALL
            SELECT LVL + 1 FROM CHRR_META WHERE LVL < 7
        ),
        CHRR_INFO AS (
            SELECT
                -- 변환 난이도: 2
                -- NVL을 IFNULL로 변환
                IFNULL(B.CO_NM, B.CUST_NM) AS FXED_FCTR29,
                CASE
                    WHEN B.CUST_KD_CD IN ('GC', 'GNP') THEN C.CHRR_NM
                    WHEN B.CUST_KD_CD = 'GEX' THEN B.REPR_NM
                    ELSE B.CUST_NM
                END AS FXED_FCTR15,
                CASE
                    WHEN B.CUST_KD_CD IN ('GC', 'GNP') THEN C.CHRR_MBL_CTPL
                    ELSE B.CUST_HPNO
                END AS FXED_FCTR17,
                CASE
                    WHEN B.CUST_KD_CD IN ('GC', 'GNP') THEN C.CHRR_MBL_CTPL
                    ELSE B.CUST_HPNO
                END AS FXED_FCTR16,
                CASE
                    WHEN B.CUST_KD_CD IN ('GC', 'GNP') THEN C.CHRR_MBL_CTPL
                    ELSE B.CUST_HPNO
                END AS VAR_FCTR7,
                CASE
                    WHEN B.CUST_KD_CD IN ('GC', 'GNP') THEN C.CHRR_EMAL_ADDR
                    ELSE B.CUST_EMAL
                END AS FXED_FCTR18,
                CASE
                    WHEN B.CUST_KD_CD IN ('GC', 'GNP') THEN C.CHRR_EMAL_ADDR
                    ELSE B.CUST_EMAL
                END AS FXED_FCTR8
            FROM TB_SPCS_CUST_M B
            LEFT OUTER JOIN TB_SPCS_CHRR_M C ON B.CUST_MGMT_ID = C.CUST_MGMT_ID
            WHERE B.CUST_MGMT_ID = #{custMgmtId}
        ),
        ATTR_META AS (
            -- 변환 난이도: 3
            -- DUAL 테이블 제거 및 VALUES 사용
            SELECT 'fxedFctr29' AS FXED_FCTR29, 'fxedFctr15' AS FXED_FCTR15,
                   'fxedFctr17' AS FXED_FCTR17, 'fxedFctr16' AS FXED_FCTR16,
                   'fxedFctr18' AS FXED_FCTR18, 'fxedFctr8' AS FXED_FCTR8,
                   'varFctr7' AS VAR_FCTR7
        )
        SELECT
            #{sbscMgmtId} AS SBSC_MGMT_ID
            , B.PLFM_PROD_ID
            , B.ATTR_SEQ
            , B.PROD_ATTR_CD
            , B.ENTR_META_CD 
            , CASE
                -- HIDDEN 처리는 속성기본값 사용
                WHEN B.ATTR_DISP_FORM_CD = 'HD' THEN IFNULL(C.ATTR_ITEM_VLUE, B.ATTR_BS_VAL)
                -- 가입유형
                WHEN B.PROD_ATTR_CD = 'BRZ0000036' AND 'Y' = #{bdlStat} THEN '번들가입'
                -- 메시지 허브이지 예외 처리
                WHEN B.ENTR_META_CD = 'varFctr7' AND 'BPZ0000015' != #{sltnId}
                    THEN A.ATTR_ITEM_VLUE
                WHEN B.ENTR_META_CD = 'fxedFctr29' AND B.PROD_ATTR_CD = 'BRZ0000019' THEN IFNULL(C.ATTR_ITEM_VLUE, A.ATTR_ITEM_VLUE)  --가입자(상호)명
                WHEN B.ENTR_META_CD = 'fxedFctr15' AND B.PROD_ATTR_CD = 'BRZ0000033' THEN IFNULL(C.ATTR_ITEM_VLUE, A.ATTR_ITEM_VLUE)  --담당자명
                WHEN B.ENTR_META_CD = 'fxedFctr16' AND B.PROD_ATTR_CD = 'BRZ0000034' THEN IFNULL(C.ATTR_ITEM_VLUE, A.ATTR_ITEM_VLUE)  --담당자전화번호
                WHEN B.ENTR_META_CD = 'fxedFctr17' AND B.PROD_ATTR_CD IN ('BRZ0000076','BRZ0000097') THEN IFNULL(C.ATTR_ITEM_VLUE, A.ATTR_ITEM_VLUE)  --휴대폰번호
                WHEN B.ENTR_META_CD IN ('fxedFctr18','fxedFctr8') AND B.PROD_ATTR_CD = 'BRZ0000037' THEN IFNULL(C.ATTR_ITEM_VLUE, A.ATTR_ITEM_VLUE)  --담당자 Email
                WHEN B.ENTR_META_CD = 'varFctr7' AND B.PROD_ATTR_CD NOT IN ('BRZ0000036','BRZ0000008') THEN IFNULL(C.ATTR_ITEM_VLUE, A.ATTR_ITEM_VLUE)  --담당자전화번호
                ELSE IFNULL(C.ATTR_ITEM_VLUE, A.ATTR_ITEM_VLUE)
            END AS ATTR_ITEM_VLUE
            , A.ATTR_ITEM_SPRM
            , A.ATTR_ITEM_VAT
            , #{custMgmtId} AS MFPN_ID
            , #{custMgmtId} AS REGI_ID
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
        LEFT OUTER JOIN (
            SELECT 
                CM.LVL,
                CASE CM.LVL
                    WHEN 1 THEN CI.FXED_FCTR29
                    WHEN 2 THEN CI.FXED_FCTR15
                    WHEN 3 THEN CI.FXED_FCTR17
                    WHEN 4 THEN CI.FXED_FCTR16
                    WHEN 5 THEN CI.FXED_FCTR18
                    WHEN 6 THEN CI.FXED_FCTR8
                    WHEN 7 THEN CI.VAR_FCTR7
                END AS ATTR_ITEM_VLUE,
                CASE CM.LVL
                    WHEN 1 THEN AM.FXED_FCTR29
                    WHEN 2 THEN AM.FXED_FCTR15
                    WHEN 3 THEN AM.FXED_FCTR17
                    WHEN 4 THEN AM.FXED_FCTR16
                    WHEN 5 THEN AM.FXED_FCTR18
                    WHEN 6 THEN AM.FXED_FCTR8
                    WHEN 7 THEN AM.VAR_FCTR7
                END AS ENTR_META_CD
            FROM CHRR_META CM
            CROSS JOIN CHRR_INFO CI
            CROSS JOIN ATTR_META AM
        ) C ON B.ENTR_META_CD = C.ENTR_META_CD
        WHERE
            A.SLTN_ID = #{sltnId}
            AND A.PROD_ID = #{plfmProdId}
            AND A.USE_YN = 'Y'
    ) AS SUBQUERY
</insert>
```

주요 변경 사항:
1. CONNECT BY LEVEL을 RECURSIVE CTE로 변환 (난이도: 4)
2. NVL 함수를 IFNULL로 변경 (난이도: 2)
3. DUAL 테이블 사용을 제거하고 VALUES 구문으로 대체 (난이도: 3)
4. SYSDATE를 NOW()로 변경 (난이도: 1)
5. WITH 절을 사용한 CTE 구조 유지 (난이도: 2)

전체적인 쿼리 구조와 로직은 유지하면서 Oracle 특화 문법을 MariaDB에 맞게 조정했습니다. 특히 CONNECT BY LEVEL 구문을 RECURSIVE CTE로 변환하는 부분이 가장 복잡했습니다. 그 외에는 대부분 함수나 문법의 직접적인 대체로 해결할 수 있었습니다.