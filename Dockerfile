# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2021 Intel Corporation

# Build the manager binary
FROM golang:1.15 as builder

WORKDIR /workspace

COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

COPY cmd/fwddp-manager/main.go main.go
COPY apis/ apis/
COPY pkg/fwddp-manager/ pkg/fwddp-manager/

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -a -o manager main.go

FROM registry.access.redhat.com/ubi8:8.4

ARG VERSION
### Required OpenShift Labels
LABEL name="Intel Ethernet Operator" \
    vendor="Intel Corporation" \
    version=$VERSION \
    release="1" \
    summary="Manages the FW and DPP updates of E810 NICs" \
    description="TODO"

WORKDIR /
COPY --from=builder /workspace/manager .
COPY assets/ assets/

ENTRYPOINT ["/manager"]
